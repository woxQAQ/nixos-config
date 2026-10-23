// Obelisk provider for Delta (the IDE) threads (not part of upstream).
//
// Delta persists threads in a proprietary replicated store, so we integrate
// through its stable CLI contract instead of parsing storage: `delta thread
// list --json` drives discovery and `delta thread show --format full <id>`
// yields one transcript buffer plus per-message byte ranges, roles and
// timestamps. Unit keys are `delta://thread/<id>`; the cursor is a numeric
// fingerprint of the list entry (name/status/summary/...), so a thread is
// re-offered when a new turn lands or its summary is regenerated. Streaming
// threads are always re-offered.
import { existsSync, readdirSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import { trunc } from "../parsing.js";
const SOURCE = "delta";
export const DELTA_CANONICAL_TRANSCRIPT_MARKER = "__delta_canonical_transcript_v1__";
function defaultDataDir(homeDir) {
  return process.platform === "darwin"
    ? join(homeDir, "Library", "Application Support", "delta")
    : join(homeDir, ".local", "share", "delta");
}
function resolveCli(homeDir) {
  const candidates = [
    process.env.OBELISK_DELTA_CLI,
    "/Applications/Delta.app/Contents/MacOS/delta",
    join(homeDir, "Applications", "Delta.app", "Contents", "MacOS", "delta"),
  ];
  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.length > 0 && existsSync(candidate))
      return candidate;
  }
  return null;
}
function runCli(cli, args, timeoutMs) {
  const result = spawnSync(cli, [...args, "--json"], {
    encoding: "utf8",
    timeout: timeoutMs,
    maxBuffer: 256 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(
      `delta ${args.join(" ")} exited ${result.status}: ${String(result.stderr).slice(0, 500)}`,
    );
  }
  return JSON.parse(result.stdout);
}
// 32-bit FNV-1a over the fields that change when a thread's transcript grows
// or settles. Stored in the cursor's numeric `mtime` slot, so it must stay a
// non-negative integer.
function fingerprint(entry) {
  const text = JSON.stringify([
    entry.name ?? null,
    entry.generated_title ?? null,
    entry.status ?? null,
    entry.summary ?? null,
    entry.archived ?? null,
  ]);
  let hash = 0x811c9dc5;
  for (let i = 0; i < text.length; i++) {
    hash ^= text.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash;
}
function cursorFingerprint(cursor) {
  if (!cursor) return null;
  const n = Number(cursor.split(":")[0]);
  return Number.isFinite(n) ? n : null;
}
function toIsoTimestamp(value) {
  // `thread show` emits ISO already; `thread list` uses "YYYY-MM-DD HH:MM:SS UTC".
  if (typeof value !== "string" || value.length === 0) return null;
  const normalized = value.endsWith(" UTC") ? `${value.slice(0, -4).replace(" ", "T")}Z` : value;
  return Number.isNaN(Date.parse(normalized)) ? null : normalized;
}
export function* parse(unit) {
  let data;
  try {
    data = runCli(unit.meta.cli, ["thread", "show", "--format", "full", unit.sessionId], 120000);
  } catch {
    // Unloadable threads (broken histories, mid-sync) must not poison the
    // whole index build. Returning no cursor leaves the unit uncatalogued,
    // so discovery offers it again next time.
    return null;
  }
  const thread =
    (Array.isArray(data) ? data : []).find((t) => t?.id === unit.sessionId) ?? data?.[0];
  if (thread === null || thread === undefined) return `${unit.meta.fingerprint}:0`;
  const buffer = Buffer.from(typeof thread.buffer === "string" ? thread.buffer : "", "utf8");
  const messages = Array.isArray(thread.messages) ? thread.messages : [];
  const records = [];
  let lastMessageUuid = null;
  let endedAt = null;
  for (const message of messages) {
    if (message === null || typeof message !== "object") continue;
    const start = Number(message.start_byte);
    const end = Number(message.end_byte);
    if (
      !Number.isInteger(start) ||
      !Number.isInteger(end) ||
      start < 0 ||
      end < start ||
      end > buffer.length
    )
      continue;
    const text = trunc(buffer.subarray(start, end).toString("utf8").trim());
    const number = Number(message.number);
    const uuid = `${unit.sessionId}-M${Number.isInteger(number) ? number : records.length + 1}`;
    const role = message.role === "assistant" ? "assistant" : "user";
    const timestamp = toIsoTimestamp(message.created_at_utc);
    if (timestamp !== null) endedAt = timestamp;
    records.push({
      kind: "message",
      uuid,
      session_id: unit.sessionId,
      type: role,
      parent_uuid: lastMessageUuid,
      timestamp,
      role,
      text,
      content_type: "text",
      is_meta: 0,
      visibility: "visible",
      model: null,
      is_sidechain: 0,
      agent_id: null,
      input_tokens: null,
      output_tokens: null,
      cwd: null,
      skill: null,
      source: SOURCE,
    });
    lastMessageUuid = uuid;
  }
  records.push({
    kind: "session",
    id: unit.sessionId,
    title: unit.meta.title ?? thread.name ?? thread.generated_title ?? null,
    project: null,
    started_at: toIsoTimestamp(unit.meta.created),
    ended_at: endedAt,
    git_branch: null,
    version: null,
    message_count: records.length,
    countMode: "total",
    jsonl_path: unit.key,
    source: SOURCE,
  });
  yield* records;
  return `${unit.meta.fingerprint}:0`;
}
function rawDelta(input) {
  const cli = resolveCli(homedir());
  if (cli === null) return null;
  const match = /-M(\d+)$/.exec(input.messageUuid);
  const threadId = typeof input.session?.id === "string" ? input.session.id : null;
  if (match === null || threadId === null) return null;
  let data;
  try {
    data = runCli(cli, ["thread", "show", "--format", "full", threadId], 120000);
  } catch {
    return null;
  }
  const thread = (Array.isArray(data) ? data : []).find((t) => t?.id === threadId) ?? data?.[0];
  if (thread === null || thread === undefined) return null;
  const wanted = Number(match[1]);
  const message = (Array.isArray(thread.messages) ? thread.messages : []).find(
    (m) => Number(m?.number) === wanted,
  );
  if (message === undefined) return null;
  const buffer = Buffer.from(typeof thread.buffer === "string" ? thread.buffer : "", "utf8");
  const text = buffer
    .subarray(Number(message.start_byte), Number(message.end_byte))
    .toString("utf8");
  return {
    text,
    totalLength: text.length,
    offset: 0,
    limit: text.length,
    hasMore: false,
    messageText: null,
  };
}
export function createDeltaProvider({
  rootDir,
  homeDir = homedir(),
  cli = resolveCli(homeDir),
} = {}) {
  const root = rootDir ?? defaultDataDir(homeDir);
  const discover = (ctx) => {
    if (cli === null) {
      if ((ctx.indexedSessions?.().length ?? 0) > 0) {
        ctx.reportIncompleteInventory?.({
          path: root,
          error: "Delta CLI not found (set OBELISK_DELTA_CLI)",
        });
      }
      return [];
    }
    let entries;
    try {
      entries = runCli(cli, ["thread", "list"], 60000);
    } catch (error) {
      ctx.reportIncompleteInventory?.(sourceInventoryIssueFor(root, error));
      return [];
    }
    const units = [];
    for (const entry of Array.isArray(entries) ? entries : []) {
      if (entry === null || typeof entry !== "object" || typeof entry.id !== "string") continue;
      const key = `delta://thread/${entry.id}`;
      const fp = fingerprint(entry);
      const streaming = entry.status === "streaming";
      if (!streaming && cursorFingerprint(ctx.lastCursor(key)) === fp) continue;
      units.push({
        key,
        sessionId: entry.id,
        meta: {
          cli,
          fingerprint: fp,
          title:
            (typeof entry.name === "string" && entry.name.length > 0 ? entry.name : null) ??
            (typeof entry.generated_title === "string" && entry.generated_title.length > 0
              ? entry.generated_title
              : null),
          created: entry.created_at_utc ?? null,
        },
      });
    }
    return units;
  };
  return {
    name: SOURCE,
    descriptor: { id: SOURCE, name: "Delta", vendor: "Delta", defaultRoot: root, color: "#0e7490" },
    indexVersionMarker: DELTA_CANONICAL_TRANSCRIPT_MARKER,
    watchTargets: (configuredRoot) => {
      // The replicated store's mtime moves with any thread activity;
      // watching the per-user databases approximates that signal.
      try {
        const dbs = readdirSync(configuredRoot, { withFileTypes: true })
          .filter((entry) => entry.isDirectory() && entry.name.startsWith("user_"))
          .map((entry) => join(configuredRoot, entry.name, "data.sqlite"))
          .filter((path) => existsSync(path));
        if (dbs.length > 0) return dbs.map((path) => ({ kind: "file", path }));
      } catch {
        /* data dir absent */
      }
      return [{ kind: "tree", path: configuredRoot }];
    },
    discover,
    parse,
    raw: rawDelta,
  };
}
function sourceInventoryIssueFor(path, error) {
  return { path, error: error instanceof Error ? error.message : String(error) };
}
export const deltaProvider = createDeltaProvider();
