// Obelisk provider for Grok CLI session history (not part of upstream).
//
// Wire layout: <root>/<urlencoded-cwd>/<session-uuid>/chat_history.jsonl, with
// a sibling summary.json carrying session metadata (cwd, title, timestamps,
// model). History lines are JSON objects with a `type` of system / user /
// reasoning / assistant / tool_result; lines carry no timestamps or uuids, so
// we synthesize stable uuids from the line number (`<sid>-L<n>`) and take
// session timestamps from summary.json.
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { isAbsolute, join, normalize } from "node:path";
import {
  trunc,
  truncJson,
  extractText,
  extractContentType,
  readLines,
  sourceInventoryIssue,
} from "../parsing.js";
const SOURCE = "grok";
export const GROK_CANONICAL_TRANSCRIPT_MARKER = "__grok_canonical_transcript_v1__";
const HISTORY_FILE = "chat_history.jsonl";
function decodeProjectSlug(slug) {
  try {
    return decodeURIComponent(slug);
  } catch {
    return null;
  }
}
function readSummary(dir) {
  const path = join(dir, "summary.json");
  if (!existsSync(path)) return null;
  try {
    const parsed = JSON.parse(readFileSync(path, "utf8"));
    return parsed !== null && typeof parsed === "object" ? parsed : null;
  } catch {
    return null;
  }
}
// Cursor format mirrors the Claude provider:
// `${mtimeMs}:${lines}:${size}:${ctimeMs}:${ino}`.
function cursorToSkip(cursor) {
  if (!cursor) return 0;
  const n = Number(cursor.split(":")[1]);
  return Number.isFinite(n) ? n : 0;
}
function cursorSignatureDiffers(cursor, filePath) {
  const stat = statSync(filePath);
  const parts = cursor.split(":");
  if (parts.length < 5) return Number(parts[0]) < stat.mtimeMs;
  return (
    Number(parts[0]) !== stat.mtimeMs ||
    Number(parts[2]) !== stat.size ||
    Number(parts[3]) !== stat.ctimeMs ||
    Number(parts[4]) !== stat.ino
  );
}
function* walkHistoryFiles(rootDir, reportIssue) {
  let projects;
  try {
    projects = readdirSync(rootDir, { withFileTypes: true });
  } catch (error) {
    reportIssue?.(sourceInventoryIssue(rootDir, error));
    return;
  }
  for (const project of projects) {
    if (!project.isDirectory()) continue;
    const projectDir = join(rootDir, project.name);
    let sessions;
    try {
      sessions = readdirSync(projectDir, { withFileTypes: true });
    } catch (error) {
      reportIssue?.(sourceInventoryIssue(projectDir, error));
      continue;
    }
    for (const session of sessions) {
      if (!session.isDirectory()) continue;
      const dir = join(projectDir, session.name);
      const file = join(dir, HISTORY_FILE);
      if (existsSync(file)) {
        yield {
          path: file,
          dir,
          sessionId: session.name,
          project: decodeProjectSlug(project.name),
        };
      }
    }
  }
}
function discoverAt(rootDir, ctx) {
  if (!existsSync(rootDir)) {
    if ((ctx.indexedSessions?.().length ?? 0) > 0) {
      ctx.reportIncompleteInventory?.({ path: rootDir, error: "Source folder is unavailable" });
    }
    return [];
  }
  const changed = new Set(
    (ctx.changedPaths ?? []).map((p) =>
      isAbsolute(p) ? normalize(p) : normalize(join(rootDir, p)),
    ),
  );
  const units = [];
  for (const file of walkHistoryFiles(rootDir, ctx.reportIncompleteInventory)) {
    const path = normalize(file.path);
    if (ctx.changedPaths !== undefined) {
      // Any change inside the session directory (history or summary)
      // re-offers the history file.
      const inUnit = changed.has(path) || changed.has(normalize(join(file.dir, "summary.json")));
      if (!inUnit) continue;
    }
    const cursor = ctx.lastCursor(path);
    if (cursor !== null && !cursorSignatureDiffers(cursor, path)) continue;
    units.push({
      key: path,
      sessionId: file.sessionId,
      project: file.project,
      meta: { dir: file.dir },
    });
  }
  return units;
}
function grokText(content) {
  if (typeof content === "string") return trunc(content);
  if (Array.isArray(content)) {
    return trunc(
      content
        .map((block) =>
          block !== null && typeof block === "object" && typeof block.text === "string"
            ? block.text
            : "",
        )
        .filter((part) => part.length > 0)
        .join("\n"),
    );
  }
  return null;
}
function toolInputFilePath(name, input) {
  if (input === null || typeof input !== "object") return null;
  if (
    ![
      "read_file",
      "write_file",
      "search_replace",
      "view_file",
      "create_file",
      "edit_file",
    ].includes(name)
  )
    return null;
  const value = input.path ?? input.file_path ?? input.filename;
  return typeof value === "string" ? value : null;
}
function parseToolArguments(raw) {
  if (typeof raw !== "string") return [truncJson(raw), null];
  try {
    const parsed = JSON.parse(raw);
    return [truncJson(parsed), parsed];
  } catch {
    return [trunc(raw), null];
  }
}
export function* parse(unit, cursor) {
  const skip = cursorToSkip(cursor);
  const stat = statSync(unit.key);
  const summary = readSummary(unit.meta?.dir ?? "") ?? {};
  const info = summary.info !== null && typeof summary.info === "object" ? summary.info : {};
  const sid = unit.sessionId;
  const sm = { n: 0 };
  // Line-numbered uuids stay stable across incremental reparses. The
  // tool-call map is rebuilt from skipped lines too, so a tool_result can
  // always name its assistant message.
  const toolCallMessages = new Map();
  const records = [];
  let lastMessageUuid = null;
  let lineNum = 0;
  let cursorLines = 0;
  readLines(unit.key, (line, terminated) => {
    lineNum++;
    let obj;
    let parsed = true;
    try {
      obj = JSON.parse(line);
    } catch {
      parsed = false;
    }
    if (parsed || terminated) cursorLines = lineNum;
    if (!parsed || obj === null || typeof obj !== "object") return;
    const type = obj.type;
    const uuid = `${sid}-L${lineNum}`;
    if (type === "assistant" && Array.isArray(obj.tool_calls)) {
      for (const call of obj.tool_calls) {
        if (call !== null && typeof call === "object" && typeof call.id === "string")
          toolCallMessages.set(call.id, uuid);
      }
    }
    if (lineNum <= skip) return;
    if (type === "user" || type === "assistant") {
      sm.n++;
      const text = grokText(obj.content);
      records.push({
        kind: "message",
        uuid,
        session_id: sid,
        type,
        parent_uuid: lastMessageUuid,
        timestamp: null,
        role: type,
        text,
        content_type: extractContentType(obj.content),
        is_meta: 0,
        visibility: "visible",
        model: typeof obj.model_id === "string" ? obj.model_id : null,
        is_sidechain: 0,
        agent_id: null,
        input_tokens: null,
        output_tokens: null,
        cwd: typeof info.cwd === "string" ? info.cwd : null,
        skill: null,
        source: SOURCE,
      });
      lastMessageUuid = uuid;
    }
    if (type === "assistant" && Array.isArray(obj.tool_calls)) {
      for (const call of obj.tool_calls) {
        if (call === null || typeof call !== "object" || typeof call.id !== "string") continue;
        const [inputJson, input] = parseToolArguments(call.arguments);
        const name = typeof call.name === "string" ? call.name : "unknown";
        records.push({
          kind: "tool_call",
          id: call.id,
          message_uuid: uuid,
          session_id: sid,
          name,
          presentation: "default",
          input_json: inputJson,
          file_path: toolInputFilePath(name, input),
        });
      }
    }
    if (type === "tool_result" && typeof obj.tool_call_id === "string") {
      records.push({
        kind: "tool_result",
        tool_use_id: obj.tool_call_id,
        message_uuid: toolCallMessages.get(obj.tool_call_id) ?? null,
        session_id: sid,
        content: grokText(obj.content),
        file_path: null,
        is_error: 0,
      });
    }
  });
  const title =
    typeof summary.session_summary === "string" && summary.session_summary.length > 0
      ? summary.session_summary
      : null;
  records.push({
    kind: "session",
    id: sid,
    title,
    project: unit.project ?? (typeof info.cwd === "string" ? info.cwd : null),
    started_at: typeof summary.created_at === "string" ? summary.created_at : null,
    ended_at: typeof summary.updated_at === "string" ? summary.updated_at : null,
    git_branch: null,
    version: null,
    message_count: sm.n,
    countMode: skip > 0 ? "delta" : "total",
    jsonl_path: unit.key,
    source: SOURCE,
  });
  yield* records;
  return `${stat.mtimeMs}:${cursorLines}:${stat.size}:${stat.ctimeMs}:${stat.ino}`;
}
function rawGrok(input) {
  const path = typeof input.session?.jsonl_path === "string" ? input.session.jsonl_path : null;
  if (path === null || !existsSync(path)) return null;
  const match = /-L(\d+)$/.exec(input.messageUuid);
  if (match === null) return null;
  const wanted = Number(match[1]);
  let found = null;
  let lineNum = 0;
  readLines(path, (line) => {
    lineNum++;
    if (lineNum === wanted) {
      found = line;
      return false;
    }
    return undefined;
  });
  return found === null
    ? null
    : {
        text: found,
        totalLength: found.length,
        offset: 0,
        limit: found.length,
        hasMore: false,
        messageText: null,
      };
}
export function createGrokProvider({ rootDir = join(homedir(), ".grok", "sessions") } = {}) {
  return {
    name: SOURCE,
    descriptor: { id: SOURCE, name: "Grok", vendor: "xAI", defaultRoot: rootDir, color: "#000000" },
    indexVersionMarker: GROK_CANONICAL_TRANSCRIPT_MARKER,
    watchTargets: (configuredRoot) => [
      { kind: "tree", path: configuredRoot, fileNames: [HISTORY_FILE, "summary.json"] },
    ],
    discover: (ctx) => discoverAt(rootDir, ctx),
    parse,
    raw: rawGrok,
  };
}
export const grokProvider = createGrokProvider();
