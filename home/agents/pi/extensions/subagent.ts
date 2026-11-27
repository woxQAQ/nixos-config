// Subagent — delegate work to background `pi` processes with isolated context.
//
// Tools (no slash commands by design):
//   subagent_create   Spawn one or more subagents in parallel; returns ids immediately.
//   subagent_wait     Block until the given subagents finish (or a timeout hits).
//   subagent_result   Read the current/final output of given subagents without blocking.
//   subagent_destroy  Kill running subagents and drop them from the registry.
//
// Viewer: `/subagents` (or ctrl+shift+s) opens an interactive browser to
// inspect each subagent's status, usage, and full message transcript.
//
// Model selection: `model` is optional and inherits the dispatching session's
// model when omitted. A specified model is resolved against the available
// catalogue; unknown or ambiguous names are errors, never a silent fallback.
// The first create call of a session appends the available model list to its
// result so the model can resolve user mentions to full provider/id strings.

import { type ChildProcess, spawn } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import type { Message } from "@earendil-works/pi-ai";
import {
  type ExtensionAPI,
  type ExtensionContext,
  type JsonAgentSessionEvent,
  type Theme,
} from "@earendil-works/pi-coding-agent";
import {
  matchesKey,
  Text,
  truncateToWidth,
  visibleWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

const MAX_TASKS_PER_CREATE = 8;
const OUTPUT_CAP_BYTES = 40 * 1024;
const KILL_GRACE_MS = 5000;
const DEFAULT_WAIT_TIMEOUT_MS = 120_000;

type Status = "running" | "completed" | "failed" | "aborted" | "destroyed";

interface UsageStats {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  turns: number;
}

interface SubagentHandle {
  id: string;
  task: string;
  /** Resolved "provider/id", or "inherit" when the task did not pin a model. */
  model: string;
  cwd: string;
  status: Status;
  proc: ChildProcess | null;
  messages: Message[];
  stderr: string;
  usage: UsageStats;
  error?: string;
  startedAt: number;
  finishedAt?: number;
  done: Promise<void>;
}

function emptyUsage(): UsageStats {
  return { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 };
}

function formatTokens(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  return `${(count / 1000000).toFixed(1)}M`;
}

function formatUsage(usage: UsageStats): string {
  const parts: string[] = [];
  if (usage.turns) parts.push(`${usage.turns} turns`);
  if (usage.input) parts.push(`↑${formatTokens(usage.input)}`);
  if (usage.output) parts.push(`↓${formatTokens(usage.output)}`);
  if (usage.cost) parts.push(`$${usage.cost.toFixed(4)}`);
  return parts.join(" ");
}

function elapsedSeconds(handle: SubagentHandle): number {
  const end = handle.finishedAt ?? Date.now();
  return Math.round((end - handle.startedAt) / 1000);
}

/** Compact duration: 42s, 12m09s, 1h07m. */
function formatElapsed(totalSeconds: number): string {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (minutes >= 60)
    return `${Math.floor(minutes / 60)}h${(minutes % 60).toString().padStart(2, "0")}m`;
  if (minutes > 0) return `${minutes}m${seconds.toString().padStart(2, "0")}s`;
  return `${seconds}s`;
}

/** "inherit(magpie/remote/codex/gpt-6.2-sol)" -> "gpt-6.2-sol". */
function shortModelLabel(model: string): string {
  const inner = /^inherit\((.+)\)$/.exec(model)?.[1] ?? model;
  return inner.split("/").pop() ?? inner;
}

/** What the subagent is doing right now, derived from its latest activity. */
function lastActivity(handle: SubagentHandle): string {
  for (let i = handle.messages.length - 1; i >= 0; i--) {
    const msg = handle.messages[i];
    if (msg.role !== "assistant") continue;
    for (let j = msg.content.length - 1; j >= 0; j--) {
      const part = msg.content[j];
      if (part.type === "toolCall") return ` ↪ ${part.name}`;
    }
    return "";
  }
  return "";
}

/** One-line summary shared by the widget and the browser's list view. */
function widgetLine(h: SubagentHandle): string {
  const time = formatElapsed(elapsedSeconds(h));
  const stats =
    h.status === "running"
      ? `${h.usage.turns}t ↑${formatTokens(h.usage.input)} ↓${formatTokens(h.usage.output)}`
      : formatUsage(h.usage) || "—";
  const activity = h.status === "running" ? lastActivity(h) : "";
  const task = h.task.replace(/\s+/g, " ").trim();
  const preview = task.length > 48 ? `${task.slice(0, 48)}…` : task;
  const err = h.status === "failed" && h.error ? ` — ${h.error.split("\n")[0].slice(0, 60)}` : "";
  return `${statusIcon(h.status)} ${h.id} ${shortModelLabel(h.model)} ${stats} ${time}${activity} · ${preview}${err}`;
}

function finalOutput(messages: Message[]): string {
  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i];
    if (msg.role === "assistant") {
      for (const part of msg.content) {
        if (part.type === "text") return part.text;
      }
    }
  }
  return "";
}

function truncate(text: string): string {
  if (Buffer.byteLength(text, "utf8") <= OUTPUT_CAP_BYTES) return text;
  let cut = text.slice(0, OUTPUT_CAP_BYTES);
  while (Buffer.byteLength(cut, "utf8") > OUTPUT_CAP_BYTES) cut = cut.slice(0, -1);
  return `${cut}\n\n[truncated; full output lives in tool details]`;
}

function statusIcon(status: Status): string {
  switch (status) {
    case "running":
      return "⏳";
    case "completed":
      return "✓";
    case "failed":
      return "✗";
    case "aborted":
      return "◼";
    case "destroyed":
      return "◼";
  }
}

/** Spawn the pi binary the same way the current process was launched. */
function getPiInvocation(args: string[]): { command: string; args: string[] } {
  const currentScript = process.argv[1];
  const isBunVirtualScript =
    currentScript !== undefined &&
    (currentScript.startsWith("/$bunfs/root/") ||
      /^[A-Za-z]:[\\/]~BUN[\\/]root[\\/]/.test(currentScript));
  if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
    return { command: process.execPath, args: [currentScript, ...args] };
  }
  const execName = path.basename(process.execPath).toLowerCase();
  if (!/^(node|bun)(\.exe)?$/.test(execName)) {
    return { command: process.execPath, args };
  }
  return { command: "pi", args };
}

type ModelResolution = { ok: true; model: string } | { ok: false; error: string };

/** Resolve a user/model-supplied name against the catalogue. Never falls back. */
function resolveModel(available: string[], query: string): ModelResolution {
  const normalized = query.trim();
  const exact = available.find((m) => m === normalized);
  if (exact) return { ok: true, model: exact };

  const lower = normalized.toLowerCase();
  const byBareId = available.filter((m) => m.split("/").pop()?.toLowerCase() === lower);
  if (byBareId.length === 1) return { ok: true, model: byBareId[0] };

  const pool = byBareId.length > 1 ? byBareId : available;
  const bySubstring = pool.filter((m) => m.toLowerCase().includes(lower));
  if (bySubstring.length === 1) return { ok: true, model: bySubstring[0] };

  if (bySubstring.length > 1) {
    const candidates = bySubstring.slice(0, 10).join(", ");
    return {
      ok: false,
      error: `Ambiguous model "${query}" (${bySubstring.length} matches: ${candidates}). Pass the full provider/id.`,
    };
  }
  return {
    ok: false,
    error: `Unknown model "${query}". No fallback is applied; pick one from the available model list.`,
  };
}

export default function (pi: ExtensionAPI) {
  const registry = new Map<string, SubagentHandle>();
  let counter = 0;
  let lastCtx: ExtensionContext | undefined;
  /** Whether the available-model list has been injected into context this session. */
  let modelListInjected = false;

  /** Open viewers (list browser and detail overlays), notified when subagent state changes. */
  const viewers = new Set<{ onUpdate(): void }>();
  /** 1s ticker so elapsed time and activity stay fresh while agents run. */
  let ticker: ReturnType<typeof setInterval> | undefined;

  function ensureTicker(): void {
    const anyRunning = [...registry.values()].some((h) => h.status === "running");
    if (anyRunning && ticker === undefined) {
      ticker = setInterval(() => {
        refreshWidget();
        for (const viewer of viewers) viewer.onUpdate();
      }, 1000);
      ticker.unref?.();
    } else if (!anyRunning && ticker !== undefined) {
      clearInterval(ticker);
      ticker = undefined;
    }
  }

  function refreshWidget(): void {
    const ctx = lastCtx;
    ensureTicker();
    if (!ctx?.hasUI) return;
    const handles = [...registry.values()];
    const running = handles.filter((h) => h.status === "running").length;

    if (handles.length === 0) {
      ctx.ui.setWidget("subagent", undefined);
      ctx.ui.setStatus("subagent", undefined);
      return;
    }

    ctx.ui.setStatus(
      "subagent",
      running > 0 ? `⚙ ${running} subagent${running > 1 ? "s" : ""} — /subagents` : undefined,
    );

    ctx.ui.setWidget("subagent", handles.map(widgetLine));
  }

  function killHandle(handle: SubagentHandle, status: Status): void {
    if (handle.status !== "running") return;
    handle.status = status;
    handle.finishedAt = Date.now();
    const proc = handle.proc;
    if (proc && proc.exitCode === null && proc.signalCode === null) {
      proc.kill("SIGTERM");
      setTimeout(() => {
        if (proc.exitCode === null && proc.signalCode === null) proc.kill("SIGKILL");
      }, KILL_GRACE_MS).unref();
    }
  }

  function launch(
    handle: SubagentHandle,
    modelArg: string | undefined,
    thinking: string | undefined,
  ): void {
    const args: string[] = ["--mode", "json", "-p", "--no-session"];
    if (modelArg) args.push("--model", modelArg);
    if (thinking) args.push("--thinking", thinking);
    args.push(`Task: ${handle.task}`);

    let resolveDone!: () => void;
    handle.done = new Promise<void>((resolve) => {
      resolveDone = resolve;
    });

    const invocation = getPiInvocation(args);
    let proc: ChildProcess;
    try {
      proc = spawn(invocation.command, invocation.args, {
        cwd: handle.cwd,
        shell: false,
        stdio: ["ignore", "pipe", "pipe"],
      });
    } catch (error) {
      handle.status = "failed";
      handle.finishedAt = Date.now();
      handle.error = error instanceof Error ? error.message : String(error);
      resolveDone();
      refreshWidget();
      return;
    }
    handle.proc = proc;

    let buffer = "";
    const processLine = (line: string) => {
      if (!line.trim()) return;
      let event: JsonAgentSessionEvent;
      try {
        event = JSON.parse(line) as JsonAgentSessionEvent;
      } catch {
        return;
      }
      if (event.type !== "message_end") return;
      const msg = event.message;
      if (msg.role !== "user" && msg.role !== "assistant" && msg.role !== "toolResult") return;
      const message = msg as Message;
      handle.messages.push(message);
      if (message.role === "assistant") {
        handle.usage.turns++;
        handle.usage.input += message.usage.input;
        handle.usage.output += message.usage.output;
        handle.usage.cacheRead += message.usage.cacheRead;
        handle.usage.cacheWrite += message.usage.cacheWrite;
        handle.usage.cost += message.usage.cost.total;
        if (message.stopReason === "error") {
          handle.error = message.errorMessage ?? "model error";
        }
      }
      refreshWidget();
    };

    proc.stdout?.on("data", (data) => {
      buffer += data.toString();
      const lines = buffer.split("\n");
      buffer = lines.pop() || "";
      for (const line of lines) processLine(line);
    });
    proc.stderr?.on("data", (data) => {
      handle.stderr += data.toString();
    });
    proc.on("error", (error) => {
      handle.error = `spawn failed: ${error.message}`;
    });
    proc.on("close", (code, signal) => {
      if (buffer.trim()) processLine(buffer);
      if (handle.status === "running") {
        handle.finishedAt = Date.now();
        if (signal) {
          handle.status = "failed";
          handle.error ||= `terminated by signal ${signal}`;
        } else if (code !== 0) {
          handle.status = "failed";
          handle.error ||= `exited with code ${code}${handle.stderr.trim() ? `: ${handle.stderr.trim().slice(0, 200)}` : ""}`;
        } else if (handle.error) {
          handle.status = "failed";
        } else {
          handle.status = "completed";
        }
      }
      handle.proc = null;
      resolveDone();
      refreshWidget();
    });
  }

  function availableModels(ctx: ExtensionContext): string[] {
    const scoped = ctx.scopedModels;
    const models =
      scoped.length > 0 ? scoped.map((s) => s.model) : ctx.modelRegistry.getAvailable();
    return models.map((m) => `${m.provider}/${m.id}`).sort();
  }

  function lookup(ids: string[]): { found: SubagentHandle[]; unknown: string[] } {
    const found: SubagentHandle[] = [];
    const unknown: string[] = [];
    for (const id of ids) {
      const handle = registry.get(id);
      if (handle) found.push(handle);
      else unknown.push(id);
    }
    return { found, unknown };
  }

  function describeHandle(handle: SubagentHandle, includeOutput: boolean): string {
    const head =
      `${statusIcon(handle.status)} ${handle.id} [${handle.model}] ${handle.status} — ${formatUsage(handle.usage)} ${elapsedSeconds(handle)}s`.trim();
    if (!includeOutput) return head;
    if (handle.status === "running") {
      return `${head}\n(still running; final output not available yet)`;
    }
    const out = finalOutput(handle.messages);
    const err = handle.error ? `\nError: ${handle.error}` : "";
    return `${head}${err}\n\n${truncate(out || handle.stderr.trim() || "(no output)")}`;
  }

  function unknownIdNote(unknown: string[]): string {
    const known = [...registry.keys()].join(", ") || "none";
    return `Unknown subagent id(s): ${unknown.join(", ")}. Live ids: ${known}.`;
  }

  function markErrorResult(details: unknown): { isError: true } | undefined {
    return (details as { isError?: boolean } | undefined)?.isError ? { isError: true } : undefined;
  }

  pi.on("session_start", async (_event, ctx) => {
    lastCtx = ctx;
    modelListInjected = false;
    registry.clear();
    counter = 0;
    refreshWidget();
  });

  pi.on("session_shutdown", async () => {
    for (const handle of registry.values()) killHandle(handle, "aborted");
  });

  pi.on("tool_result", (event) => {
    if (!event.toolName.startsWith("subagent_")) return;
    return markErrorResult(event.details);
  });

  const ModelParam = Type.Optional(
    Type.String({
      description:
        'Full "provider/id" (e.g. "anthropic/claude-sonnet-4-5"). Omit to inherit the current session model. Unknown or ambiguous names are an error — never silently fall back.',
    }),
  );

  pi.registerTool({
    name: "subagent_create",
    label: "Subagent Create",
    description: [
      "Spawn background subagents (isolated `pi` processes) and return their ids immediately.",
      "Pass several tasks to run them in parallel.",
      "Use subagent_wait / subagent_result / subagent_destroy with the returned ids for follow-up.",
    ].join(" "),
    parameters: Type.Object({
      tasks: Type.Array(
        Type.Object({
          task: Type.String({ description: "Self-contained task for the subagent" }),
          model: ModelParam,
          cwd: Type.Optional(
            Type.String({ description: "Working directory; defaults to the session cwd" }),
          ),
        }),
        { description: `Tasks to run in parallel (max ${MAX_TASKS_PER_CREATE})`, minItems: 1 },
      ),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      lastCtx = ctx;
      if (params.tasks.length > MAX_TASKS_PER_CREATE) {
        return {
          content: [
            {
              type: "text",
              text: `Too many tasks (${params.tasks.length}); max is ${MAX_TASKS_PER_CREATE} per call.`,
            },
          ],
          details: { created: [], isError: true },
        };
      }

      const catalogue = availableModels(ctx);
      const inherited = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;
      const created: SubagentHandle[] = [];
      const failures: string[] = [];

      for (const spec of params.tasks) {
        let modelArg: string | undefined;
        let modelLabel: string;
        let thinking: string | undefined;
        if (spec.model) {
          const resolved = resolveModel(catalogue, spec.model);
          if (!resolved.ok) {
            failures.push(`task ${JSON.stringify(spec.task.slice(0, 50))}: ${resolved.error}`);
            continue;
          }
          modelArg = resolved.model;
          modelLabel = resolved.model;
        } else {
          modelArg = inherited;
          modelLabel = inherited ? `inherit(${inherited})` : "inherit(default)";
          thinking = ctx.thinkingLevel;
        }

        const handle: SubagentHandle = {
          id: `sa-${++counter}`,
          task: spec.task,
          model: modelLabel,
          cwd: spec.cwd ? path.resolve(ctx.cwd, spec.cwd) : ctx.cwd,
          status: "running",
          proc: null,
          messages: [],
          stderr: "",
          usage: emptyUsage(),
          startedAt: Date.now(),
          done: Promise.resolve(),
        };
        launch(handle, modelArg, thinking);
        registry.set(handle.id, handle);
        created.push(handle);
      }
      refreshWidget();

      const lines: string[] = [];
      if (created.length > 0) {
        lines.push(`Created ${created.length} subagent(s), running in background:`);
        for (const h of created) {
          lines.push(`- ${h.id} [${h.model}] ${h.task.split("\n")[0].slice(0, 80)}`);
        }
        lines.push("Use subagent_wait or subagent_result with these ids.");
      }
      if (failures.length > 0) {
        lines.push("", "Failed to create:", ...failures.map((f) => `- ${f}`));
      }
      if (!modelListInjected) {
        modelListInjected = true;
        lines.push(
          "",
          "Available models (resolve user-mentioned names against this list and pass the full provider/id):",
          ...catalogue,
        );
      }

      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: {
          created: created.map((h) => ({ id: h.id, model: h.model, task: h.task })),
          failures,
          isError: created.length === 0 && failures.length > 0,
        },
      };
    },

    renderCall(args, theme) {
      let text =
        theme.fg("toolTitle", theme.bold("subagent_create ")) +
        theme.fg("accent", `${args.tasks?.length ?? 0} task(s)`);
      for (const t of (args.tasks ?? []).slice(0, 4)) {
        const preview = t.task.split("\n")[0];
        const model = t.model ? theme.fg("warning", ` [${t.model}]`) : "";
        text += `\n  ${theme.fg("dim", preview.length > 60 ? `${preview.slice(0, 60)}...` : preview)}${model}`;
      }
      if ((args.tasks?.length ?? 0) > 4) {
        text += `\n  ${theme.fg("muted", `... +${args.tasks.length - 4} more`)}`;
      }
      return new Text(text, 0, 0);
    },

    renderResult(result, _options, theme) {
      const details = result.details as
        | { created: { id: string; model: string; task: string }[]; failures: string[] }
        | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "(no output)", 0, 0);
      }
      let text = "";
      for (const c of details.created) {
        text += `${theme.fg("success", "✓")} ${theme.fg("accent", c.id)} ${theme.fg("muted", c.model)}\n`;
      }
      for (const f of details.failures) {
        text += `${theme.fg("error", "✗")} ${theme.fg("error", f)}\n`;
      }
      return new Text(text.trimEnd() || theme.fg("muted", "(nothing created)"), 0, 0);
    },
  });

  const IdsParam = Type.Array(Type.String({ description: 'Subagent id, e.g. "sa-1"' }), {
    minItems: 1,
  });

  pi.registerTool({
    name: "subagent_wait",
    label: "Subagent Wait",
    description:
      "Block until the given subagents finish or the timeout elapses. Returns final outputs of finished ones and lists any still running.",
    parameters: Type.Object({
      ids: IdsParam,
      timeout_ms: Type.Optional(
        Type.Number({ description: `Max wait in ms. Default ${DEFAULT_WAIT_TIMEOUT_MS}.` }),
      ),
    }),

    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      lastCtx = ctx;
      const { found, unknown } = lookup(params.ids);
      const pending = found.filter((h) => h.status === "running");
      const timeout = params.timeout_ms ?? DEFAULT_WAIT_TIMEOUT_MS;

      if (pending.length > 0) {
        await Promise.race([
          Promise.allSettled(pending.map((h) => h.done)),
          new Promise<"timeout" | "aborted">((resolve) => {
            const timer = setTimeout(() => resolve("timeout"), timeout);
            signal?.addEventListener(
              "abort",
              () => {
                clearTimeout(timer);
                resolve("aborted");
              },
              { once: true },
            );
          }),
        ]);
      }
      refreshWidget();

      const lines: string[] = [];
      if (unknown.length > 0) lines.push(unknownIdNote(unknown), "");
      const stillRunning = found.filter((h) => h.status === "running");
      for (const h of found.filter((h) => h.status !== "running")) {
        lines.push(describeHandle(h, true), "");
      }
      if (stillRunning.length > 0) {
        lines.push(
          `Still running after wait: ${stillRunning.map((h) => `${h.id} (${h.usage.turns} turns, ${elapsedSeconds(h)}s)`).join(", ")}. Call subagent_wait again or subagent_result to peek.`,
        );
      }
      return {
        content: [{ type: "text", text: lines.join("\n").trim() || "(nothing to report)" }],
        details: {
          results: found.map((h) => ({
            id: h.id,
            status: h.status,
            output: finalOutput(h.messages),
            error: h.error,
            usage: h.usage,
          })),
          unknown,
        },
      };
    },

    renderCall(args, theme) {
      const timeout = args.timeout_ms ? ` ${Math.round(args.timeout_ms / 1000)}s` : "";
      return new Text(
        theme.fg("toolTitle", theme.bold("subagent_wait ")) +
          theme.fg("accent", (args.ids ?? []).join(", ")) +
          theme.fg("muted", timeout),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as
        | { results: { id: string; status: Status; error?: string }[]; unknown: string[] }
        | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "(no output)", 0, 0);
      }
      const lines = details.results.map((r) => {
        const icon =
          r.status === "completed"
            ? theme.fg("success", "✓")
            : r.status === "running"
              ? theme.fg("warning", "⏳")
              : theme.fg("error", "✗");
        return `${icon} ${theme.fg("accent", r.id)} ${theme.fg("muted", r.status)}${r.error ? theme.fg("error", ` — ${r.error.split("\n")[0].slice(0, 60)}`) : ""}`;
      });
      for (const id of details.unknown) lines.push(theme.fg("error", `✗ ${id} unknown`));
      return new Text(lines.join("\n") || theme.fg("muted", "(nothing)"), 0, 0);
    },
  });

  pi.registerTool({
    name: "subagent_result",
    label: "Subagent Result",
    description:
      "Read the current state and output of the given subagents without blocking. Finished subagents return their final output; running ones return progress only.",
    parameters: Type.Object({ ids: IdsParam }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      lastCtx = ctx;
      const { found, unknown } = lookup(params.ids);
      const lines: string[] = [];
      if (unknown.length > 0) lines.push(unknownIdNote(unknown), "");
      for (const h of found) lines.push(describeHandle(h, true), "");
      return {
        content: [{ type: "text", text: lines.join("\n").trim() || "(nothing to report)" }],
        details: {
          results: found.map((h) => ({
            id: h.id,
            status: h.status,
            output: h.status === "running" ? undefined : finalOutput(h.messages),
            error: h.error,
            usage: h.usage,
          })),
          unknown,
        },
      };
    },

    renderCall(args, theme) {
      return new Text(
        theme.fg("toolTitle", theme.bold("subagent_result ")) +
          theme.fg("accent", (args.ids ?? []).join(", ")),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const text = result.content[0];
      const raw = text?.type === "text" ? text.text : "(no output)";
      const preview = raw.split("\n").slice(0, 12).join("\n");
      return new Text(
        theme.fg("toolOutput", preview) +
          (raw.split("\n").length > 12 ? theme.fg("muted", "\n(Ctrl+O to expand)") : ""),
        0,
        0,
      );
    },
  });

  pi.registerTool({
    name: "subagent_destroy",
    label: "Subagent Destroy",
    description:
      "Kill the given subagents (SIGTERM, then SIGKILL) and remove them from the registry. Ids become invalid afterwards.",
    parameters: Type.Object({ ids: IdsParam }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      lastCtx = ctx;
      const { found, unknown } = lookup(params.ids);
      const lines: string[] = [];
      for (const h of found) {
        killHandle(h, "destroyed");
        registry.delete(h.id);
        lines.push(`◼ ${h.id} destroyed`);
      }
      if (unknown.length > 0) lines.push(unknownIdNote(unknown));
      refreshWidget();
      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: { destroyed: found.map((h) => h.id), unknown, isError: found.length === 0 },
      };
    },

    renderCall(args, theme) {
      return new Text(
        theme.fg("toolTitle", theme.bold("subagent_destroy ")) +
          theme.fg("warning", (args.ids ?? []).join(", ")),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as { destroyed: string[]; unknown: string[] } | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "(no output)", 0, 0);
      }
      const lines = details.destroyed.map(
        (id) =>
          `${theme.fg("muted", "◼")} ${theme.fg("accent", id)} ${theme.fg("muted", "destroyed")}`,
      );
      for (const id of details.unknown) lines.push(theme.fg("error", `✗ ${id} unknown`));
      return new Text(lines.join("\n") || theme.fg("muted", "(nothing destroyed)"), 0, 0);
    },
  });

  // ---------------------------------------------------------------------------
  // Interactive browser: `/subagents` or ctrl+shift+s.
  // The list shows one widgetLine per handle; pressing enter opens the full
  // transcript (task, usage, every message, tool calls and results) in a
  // floating overlay stacked above the list.
  // ---------------------------------------------------------------------------

  function messageText(msg: Message): string {
    const content = msg.content;
    if (typeof content === "string") return content;
    if (!Array.isArray(content)) return "";
    const parts: string[] = [];
    for (const part of content) {
      if (part.type === "text") parts.push(part.text);
      else if (part.type === "thinking") parts.push(`[thinking] ${part.thinking}`);
      else if (part.type === "image") parts.push("[image]");
    }
    return parts.join("\n");
  }

  /** Build the styled, wrapped transcript lines for the detail view. */
  function buildTranscript(h: SubagentHandle, theme: Theme, width: number): string[] {
    const lines: string[] = [];
    const wrapWidth = Math.max(20, width - 4);
    const pushWrapped = (text: string, style: (s: string) => string, indent = "  ") => {
      for (const raw of text.split("\n")) {
        for (const wrapped of wrapTextWithAnsi(raw, wrapWidth - visibleWidth(indent))) {
          lines.push(style(indent + wrapped));
        }
      }
    };
    const section = (label: string, color: Parameters<Theme["fg"]>[0]) =>
      lines.push(
        theme.fg(color, `── ${label} ${"─".repeat(Math.max(0, wrapWidth - label.length - 4))}`),
      );

    for (const msg of h.messages) {
      if (msg.role === "user") {
        section("user", "accent");
        pushWrapped(messageText(msg) || "(empty)", (s) => s);
      } else if (msg.role === "assistant") {
        section("assistant", "success");
        let wrote = false;
        for (const part of msg.content) {
          if (part.type === "text") {
            pushWrapped(part.text, (s) => s);
            wrote = true;
          } else if (part.type === "thinking") {
            pushWrapped(part.thinking, (s) => theme.fg("dim", s));
            wrote = true;
          } else if (part.type === "toolCall") {
            const args = JSON.stringify(part.arguments ?? {});
            lines.push(
              theme.fg("warning", `  ▶ ${part.name} `) +
                theme.fg("dim", args.length > 120 ? `${args.slice(0, 120)}…` : args),
            );
            wrote = true;
          }
        }
        if (!wrote) lines.push(theme.fg("muted", "  (no content)"));
      } else if (msg.role === "toolResult") {
        const isError = "isError" in msg && Boolean((msg as { isError?: boolean }).isError);
        section(isError ? "result (error)" : "result", isError ? "error" : "muted");
        // Results can be huge; keep the head so scrolling stays cheap.
        const text = messageText(msg) || "(empty)";
        const head = text.split("\n").slice(0, 8).join("\n");
        pushWrapped(head, (s) => theme.fg("dim", s));
        const total = text.split("\n").length;
        if (total > 8) lines.push(theme.fg("muted", `  … ${total - 8} more lines`));
      }
    }
    if (h.messages.length === 0) lines.push(theme.fg("muted", "  (no messages yet)"));
    if (h.status === "running") lines.push(theme.fg("warning", "  … still running …"));
    return lines;
  }

  class SubagentBrowser {
    private selected = 0;

    constructor(
      private tui: { requestRender(): void },
      private theme: Theme,
      private openDetail: (id: string) => void,
      private done: () => void,
    ) {}

    /** Called by the ticker while the browser is open. */
    onUpdate(): void {
      this.tui.requestRender();
    }

    invalidate(): void {}

    private handles(): SubagentHandle[] {
      return [...registry.values()];
    }

    handleInput(data: string): void {
      if (matchesKey(data, "escape") || data === "q") {
        this.done();
        return;
      }
      const handles = this.handles();
      if (handles.length === 0) return;
      if (matchesKey(data, "up") || data === "k") {
        this.selected = (this.selected - 1 + handles.length) % handles.length;
      } else if (matchesKey(data, "down") || data === "j") {
        this.selected = (this.selected + 1) % handles.length;
      } else if (matchesKey(data, "return") || matchesKey(data, "enter")) {
        const h = handles[this.selected];
        if (!h) return;
        this.openDetail(h.id);
        return;
      } else if (data === "d") {
        const h = handles[this.selected];
        if (!h) return;
        killHandle(h, "destroyed");
        registry.delete(h.id);
        this.selected = Math.min(this.selected, Math.max(0, this.handles().length - 1));
        refreshWidget();
      } else {
        return;
      }
      this.tui.requestRender();
    }

    render(width: number): string[] {
      const th = this.theme;
      const handles = this.handles();
      const lines: string[] = [
        th.fg("accent", th.bold("Subagents")) + th.fg("dim", `  ${handles.length} total`),
      ];
      if (handles.length === 0) {
        lines.push(th.fg("muted", "  (none yet)"));
      }
      handles.forEach((h, i) => {
        const cursor = i === this.selected ? th.fg("accent", "▸ ") : "  ";
        lines.push(cursor + widgetLine(h));
      });
      lines.push("", th.fg("dim", "↑/↓ move · enter details · d destroy · esc close"));
      return lines.map((l) => truncateToWidth(l, width));
    }
  }

  /** Floating transcript view for one subagent, stacked over the list. */
  class SubagentDetail {
    private scroll = 0;
    /** Follow the tail of a running subagent's transcript. */
    private follow = true;
    private cacheKey = "";
    private cacheLines: string[] = [];

    constructor(
      private id: string,
      private tui: { requestRender(): void },
      private theme: Theme,
      private done: () => void,
    ) {}

    /** Called by the ticker while this overlay is open. */
    onUpdate(): void {
      if (this.follow) this.scroll = Number.MAX_SAFE_INTEGER;
      this.tui.requestRender();
    }

    invalidate(): void {
      this.cacheKey = "";
    }

    /** Viewport rows; leaves room for the header and footer within the overlay. */
    private pageLines(): number {
      return Math.max(4, Math.floor((process.stdout.rows ?? 24) * 0.85) - 7);
    }

    handleInput(data: string): void {
      if (matchesKey(data, "escape") || matchesKey(data, "backspace") || data === "q") {
        this.done();
        return;
      }
      const page = this.pageLines();
      if (matchesKey(data, "up") || data === "k") {
        this.scroll -= 1;
        this.follow = false;
      } else if (matchesKey(data, "down") || data === "j") {
        this.scroll += 1;
      } else if (matchesKey(data, "pageUp") || data === "b") {
        this.scroll -= page;
        this.follow = false;
      } else if (matchesKey(data, "pageDown") || data === " ") {
        this.scroll += page;
      } else if (matchesKey(data, "home") || data === "g") {
        this.scroll = 0;
        this.follow = false;
      } else if (matchesKey(data, "end") || data === "G") {
        this.scroll = Number.MAX_SAFE_INTEGER;
        this.follow = true;
      } else {
        return;
      }
      this.tui.requestRender();
    }

    render(width: number): string[] {
      const th = this.theme;
      const h = registry.get(this.id);
      if (!h) {
        return [th.fg("muted", `  ${this.id} is gone — esc to close`)];
      }

      const cacheKey = `${h.id}:${h.messages.length}:${h.usage.turns}:${h.status}:${width}`;
      if (cacheKey !== this.cacheKey) {
        this.cacheLines = buildTranscript(h, th, Math.max(20, width - 2));
        this.cacheKey = cacheKey;
      }

      const header: string[] = [
        th.fg("accent", th.bold(`${statusIcon(h.status)} ${h.id}`)) +
          ` ${th.fg("muted", h.status)} ${th.fg("muted", h.model)}`,
        th.fg(
          "muted",
          `  ${formatUsage(h.usage) || "—"} · elapsed ${formatElapsed(elapsedSeconds(h))}`,
        ),
        th.fg(
          "dim",
          `  task: ${h.task
            .replace(/\s+/g, " ")
            .trim()
            .slice(0, Math.max(20, width - 10))}`,
        ),
      ];
      if (h.error) header.push(th.fg("error", `  error: ${h.error.split("\n")[0]}`));
      header.push(th.fg("dim", "─".repeat(Math.max(10, width - 4))));

      const viewH = this.pageLines();
      const maxScroll = Math.max(0, this.cacheLines.length - viewH);
      this.scroll = Math.max(0, Math.min(this.scroll, maxScroll));
      if (this.scroll >= maxScroll) this.follow = true;

      const slice = this.cacheLines.slice(this.scroll, this.scroll + viewH);
      const footer =
        this.cacheLines.length > viewH
          ? th.fg(
              "dim",
              `lines ${this.scroll + 1}-${Math.min(this.scroll + viewH, this.cacheLines.length)}/${this.cacheLines.length} · ↑/↓ scroll · space/b page · g/G top/bottom · esc close`,
            )
          : th.fg("dim", "esc close");
      return [...header, ...slice, footer].map((l) => truncateToWidth(l, width));
    }
  }

  /** Open the transcript of one subagent in a floating overlay above the list. */
  function openDetailView(ctx: ExtensionContext, id: string): void {
    let detail: SubagentDetail | undefined;
    const settled = ctx.ui.custom<undefined>(
      (tui, theme, _keybindings, done) => {
        detail = new SubagentDetail(id, tui, theme, () => done(undefined));
        viewers.add(detail);
        return detail;
      },
      {
        overlay: true,
        overlayOptions: {
          anchor: "center",
          width: "85%",
          maxHeight: Math.floor((process.stdout.rows ?? 24) * 0.85),
        },
      },
    );
    const cleanup = () => {
      if (detail) viewers.delete(detail);
    };
    void settled.then(cleanup, cleanup);
  }

  async function showBrowser(ctx: ExtensionContext): Promise<void> {
    if (!ctx.hasUI) return;
    lastCtx = ctx;
    let browser: SubagentBrowser | undefined;
    try {
      await ctx.ui.custom<undefined>((tui, theme, _keybindings, done) => {
        browser = new SubagentBrowser(
          tui,
          theme,
          (id) => openDetailView(ctx, id),
          () => done(undefined),
        );
        viewers.add(browser);
        return browser;
      });
    } finally {
      if (browser) viewers.delete(browser);
    }
  }

  pi.registerCommand("subagents", {
    description: "Browse subagents and inspect their transcripts",
    handler: async (_args, ctx) => {
      await showBrowser(ctx);
    },
  });

  pi.registerShortcut("ctrl+shift+s", {
    description: "Browse subagents",
    handler: async (ctx) => {
      await showBrowser(ctx);
    },
  });
}
