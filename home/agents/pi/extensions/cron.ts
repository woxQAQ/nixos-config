// Cron — repeat a prompt through a background subagent on a fixed interval.
//
// Commands:
//   /cron <interval> [<model>] <prompt>   start a job; the first iteration runs now
//   /cron                                list jobs
//   /cron stop [<id>...]                 stop one job (or all) after its current run
//
// Tools (so the orchestrating agent can steer the loop it started):
//   cron_list     Jobs, their iteration counts, last result, and next tick.
//   cron_stop     End jobs; an iteration already running is allowed to finish.
//   cron_update   Change a job's prompt, interval, or model for later iterations.
//
// Division of labour: every tick dispatches a subagent (through the subagent
// extension's event-bus service) that advances the work, and the subagent's
// report is handed back to the main agent as a message. The main agent
// orchestrates and validates: it accepts the result and stops the loop, steers
// the next iteration, or lets it run again.
//
// Scheduling is fixed-rate. A tick that fires while the previous iteration is
// still running is skipped and counted, never queued, so a slow iteration can
// not pile up subagents. State is session-scoped: timers live in this process
// and are dropped on shutdown, reload, or a session switch.

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { availableModels, resolveModel, resolveModelToken } from "./lib/model-choice.ts";
import {
  SUBAGENT_FINISHED_CHANNEL,
  SUBAGENT_SERVICE_CHANNEL,
  type SubagentEndStatus,
  type SubagentFinishedEvent,
  type SubagentService,
  type SubagentServiceReply,
} from "./lib/subagent-bus.ts";

const MAX_JOBS = 16;
const MIN_INTERVAL_MS = 30_000;
/** Recent iterations kept per job; the prompts and reports themselves are not small. */
const RUN_HISTORY_LIMIT = 20;
/** Output carried from an iteration into the next one's task. */
const TASK_CONTEXT_CAP = 2_000;
/** Output carried into the main agent's notification. */
const NOTIFY_OUTPUT_CAP = 2_500;
const UI_REFRESH_MS = 5_000;

const USAGE = [
  "Usage:",
  "  /cron <interval> [<model>] <prompt>   start a job (first iteration runs now)",
  "  /cron                                 list jobs",
  "  /cron stop [<id>...]                  stop one job, or all when no id is given",
  "",
  "interval: s/m/h, decimals allowed, e.g. 30m, 1h, 0.5h, 1h30m (minimum 30s)",
  'model: full "provider/id" or a bare model id; omit to inherit the session model',
].join("\n");

const UNIT_MS: Record<string, number> = { s: 1000, m: 60_000, h: 3_600_000 };

/** One dispatch of a job. Only recent runs are kept; `iteration` survives pruning. */
interface CronRun {
  iteration: number;
  subagentId: string;
  /** The prompt and interval this iteration was dispatched with, frozen for the report. */
  prompt: string;
  intervalText: string;
  startedAt: number;
  status: SubagentEndStatus | "running";
  endedAt?: number;
  output?: string;
  error?: string;
}

interface CronJob {
  id: string;
  intervalMs: number;
  /** The interval as typed, for display. */
  intervalText: string;
  /** Resolved provider/id, or undefined to inherit the dispatching session model. */
  model?: string;
  prompt: string;
  createdAt: number;
  /** Iterations started so far; keeps counting after old runs are pruned. */
  iterations: number;
  /** Recent runs, newest last. */
  runs: CronRun[];
  /** Ticks skipped because the previous iteration was still running. */
  skipped: number;
  nextRunAt: number;
  timer?: ReturnType<typeof setTimeout>;
  /** Set by cron_stop: no further ticks; an in-flight iteration may finish. */
  stopRequested: boolean;
}

interface NewJobSpec {
  intervalMs: number;
  intervalText: string;
  model?: string;
  prompt: string;
}

/** Parse "30m", "1h", "0.5h" or "1h30m" into milliseconds. Units are case-insensitive. */
function parseInterval(text: string): number | undefined {
  const normalized = text.trim().toLowerCase();
  if (!/^\d+(?:\.\d+)?[smh](?:\d+(?:\.\d+)?[smh])*$/.test(normalized)) return undefined;
  let total = 0;
  for (const [, amount, unit] of normalized.matchAll(/(\d+(?:\.\d+)?)([smh])/g)) {
    total += Number(amount) * UNIT_MS[unit];
  }
  return total;
}

/** Compact duration: 42s, 12m09s, 1h07m. */
function formatDuration(ms: number): string {
  const totalSeconds = Math.max(0, Math.round(ms / 1000));
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  if (hours > 0) return `${hours}h${minutes.toString().padStart(2, "0")}m`;
  if (minutes > 0) return `${minutes}m${seconds.toString().padStart(2, "0")}s`;
  return `${seconds}s`;
}

function statusIcon(status: CronRun["status"] | undefined): string {
  switch (status) {
    case "running":
      return "⏳";
    case "completed":
      return "✓";
    case "failed":
      return "✗";
    case "aborted":
    case "destroyed":
      return "◼";
    default:
      return "·";
  }
}

/** "anthropic/deepseek-v3" -> "deepseek-v3". */
function shortModel(model: string): string {
  const inner = /^inherit\((.+)\)$/.exec(model)?.[1] ?? model;
  return inner.split("/").pop() ?? inner;
}

function trimText(text: string, max: number): string {
  const trimmed = text.trim();
  if (trimmed.length <= max) return trimmed;
  return `${trimmed.slice(0, max)}\n… (${trimmed.length - max} chars trimmed)`;
}

export default function (pi: ExtensionAPI) {
  const jobs = new Map<string, CronJob>();
  let counter = 0;
  let lastCtx: ExtensionContext | undefined;
  let uiTicker: ReturnType<typeof setInterval> | undefined;
  let shuttingDown = false;

  function activeRun(job: CronJob): CronRun | undefined {
    const last = job.runs[job.runs.length - 1];
    return last?.status === "running" ? last : undefined;
  }

  function lastFinishedRun(job: CronJob): CronRun | undefined {
    for (let i = job.runs.length - 1; i >= 0; i--) {
      if (job.runs[i].status !== "running") return job.runs[i];
    }
    return undefined;
  }

  function jobLine(job: CronJob): string {
    const run = activeRun(job);
    const last = lastFinishedRun(job);
    const state = job.stopRequested
      ? "stopping after this iteration"
      : run
        ? `running ${run.subagentId} ${formatDuration(Date.now() - run.startedAt)}`
        : `next in ${formatDuration(job.nextRunAt - Date.now())}`;
    const stats = `${job.iterations} run${job.iterations === 1 ? "" : "s"}${job.skipped ? `, ${job.skipped} skipped` : ""}`;
    const lastNote = last
      ? `${statusIcon(last.status)} ${last.status} #${last.iteration}`
      : run
        ? `#${run.iteration} in flight`
        : "not run yet";
    const preview = job.prompt.replace(/\s+/g, " ").trim();
    const short = preview.length > 48 ? `${preview.slice(0, 48)}…` : preview;
    return `⏱ ${job.id} ${job.intervalText} ${shortModel(job.model ?? "inherit")} · ${stats} · ${lastNote} · ${state} · ${short}`;
  }

  function ensureUiTicker(): void {
    if (jobs.size > 0 && uiTicker === undefined) {
      uiTicker = setInterval(refreshUi, UI_REFRESH_MS);
      uiTicker.unref?.();
    } else if (jobs.size === 0 && uiTicker !== undefined) {
      clearInterval(uiTicker);
      uiTicker = undefined;
    }
  }

  function refreshUi(): void {
    ensureUiTicker();
    const ctx = lastCtx;
    if (!ctx?.hasUI) return;
    if (jobs.size === 0) {
      ctx.ui.setWidget("cron", undefined);
      ctx.ui.setStatus("cron", undefined);
      return;
    }
    ctx.ui.setStatus("cron", `⏱ ${jobs.size} cron job${jobs.size > 1 ? "s" : ""} — /cron`);
    ctx.ui.setWidget("cron", [...jobs.values()].map(jobLine));
  }

  /** Ask the subagent extension for its live registry; undefined when it is not loaded. */
  function requestSubagentService(): SubagentService | undefined {
    let service: SubagentService | undefined;
    const reply: SubagentServiceReply = (replied) => {
      service = replied;
    };
    pi.events.emit(SUBAGENT_SERVICE_CHANNEL, reply);
    return service;
  }

  function schedule(job: CronJob, delayMs: number): void {
    if (job.timer) clearTimeout(job.timer);
    const delay = Math.max(0, delayMs);
    job.nextRunAt = Date.now() + delay;
    job.timer = setTimeout(() => tick(job), delay);
    job.timer.unref?.();
    refreshUi();
  }

  /**
   * The task a tick hands to its subagent. Iterations share no context, so the
   * previous report travels with the prompt; without it a fresh subagent can
   * only infer progress from the working tree.
   */
  function buildTask(job: CronJob, iteration: number): string {
    const parts = [
      job.prompt,
      "",
      "---",
      `Scheduled iteration #${iteration} of cron job ${job.id}, fired every ${job.intervalText}. An orchestrating agent reviews your report once you finish.`,
    ];
    const previous = lastFinishedRun(job);
    if (previous) {
      const report = trimText(previous.output || previous.error || "", TASK_CONTEXT_CAP);
      if (report) {
        parts.push("", `Report from the previous iteration (#${previous.iteration}):`, report);
      }
    }
    return parts.join("\n");
  }

  /** Deliver an iteration's outcome to the orchestrating agent. */
  function notifyMain(job: CronJob, run: CronRun): void {
    const lines = [
      `${statusIcon(run.status)} ${job.id} iteration #${run.iteration} ${run.status} — subagent ${run.subagentId}, every ${run.intervalText}${job.model ? `, ${job.model}` : ""}`,
    ];
    if (run.error) lines.push(`Error: ${run.error.split("\n")[0]}`);
    lines.push("", "Prompt:", run.prompt.trim(), "");
    lines.push("Result:", trimText(run.output ?? "", NOTIFY_OUTPUT_CAP) || "(no output)", "");

    if (job.stopRequested) {
      lines.push("This job was stopped; no further iterations are scheduled.");
    } else {
      const skipped =
        job.skipped > 0 ? ` (${job.skipped} tick(s) skipped while a run was going)` : "";
      lines.push(
        "An iteration just finished. The prompt above is a recurring instruction, not a one-shot goal:",
        `the default is to do nothing and let the loop continue (next tick in ${formatDuration(job.nextRunAt - Date.now())}${skipped}).`,
        `- Work is definitively complete, or this loop should be replaced → cron_stop("${job.id}").`,
        "- Later iterations need different instructions → cron_update.",
        "- Otherwise → leave it running.",
      );
    }

    pi.sendMessage(
      {
        customType: "cron",
        content: lines.join("\n"),
        display: true,
        details: {
          jobId: job.id,
          iteration: run.iteration,
          subagentId: run.subagentId,
          status: run.status,
          nextRunAt: job.nextRunAt,
        },
      },
      { triggerTurn: true, deliverAs: "followUp" },
    );
  }

  function stopJob(job: CronJob): void {
    job.stopRequested = true;
    if (job.timer) {
      clearTimeout(job.timer);
      job.timer = undefined;
    }
    // An iteration already running keeps running: killing it mid-edit could
    // leave the working tree half-changed. It is removed when that run lands.
    if (!activeRun(job)) jobs.delete(job.id);
    refreshUi();
  }

  /** Stop a job that cannot continue (no subagent extension, spawn failure). */
  function failJob(job: CronJob, reason: string): void {
    stopJob(job);
    if (shuttingDown) return;
    pi.sendMessage(
      {
        customType: "cron",
        content: `✗ ${job.id} stopped: ${reason}`,
        display: true,
        details: { jobId: job.id, error: reason },
      },
      { triggerTurn: true, deliverAs: "followUp" },
    );
  }

  function tick(job: CronJob): void {
    job.timer = undefined;
    if (shuttingDown || job.stopRequested) return;

    // Fixed-rate: book the next tick before running, so a slow iteration only
    // skips intervening ticks instead of shifting the whole schedule.
    schedule(job, job.intervalMs);

    if (activeRun(job)) {
      job.skipped++;
      refreshUi();
      return;
    }
    const ctx = lastCtx;
    if (!ctx) return;

    const service = requestSubagentService();
    if (!service) {
      failJob(job, "the subagent extension is not loaded (subagent.ts)");
      return;
    }

    const iteration = job.iterations + 1;
    const result = service.create([{ task: buildTask(job, iteration), model: job.model }], ctx);
    if (result.created.length === 0) {
      failJob(job, result.failures.join("; ") || "subagent creation failed");
      return;
    }
    const handle = result.created[0];
    job.iterations = iteration;
    job.runs.push({
      iteration,
      subagentId: handle.id,
      prompt: job.prompt,
      intervalText: job.intervalText,
      startedAt: Date.now(),
      status: "running",
    });
    if (job.runs.length > RUN_HISTORY_LIMIT) job.runs.shift();
    refreshUi();
  }

  function startJob(spec: NewJobSpec, ctx: ExtensionContext): CronJob | string {
    if (jobs.size >= MAX_JOBS) {
      return `Already ${jobs.size} cron jobs; the maximum is ${MAX_JOBS}. Stop one first.`;
    }
    lastCtx = ctx;
    const job: CronJob = {
      id: `cron-${++counter}`,
      intervalMs: spec.intervalMs,
      intervalText: spec.intervalText,
      model: spec.model,
      prompt: spec.prompt,
      createdAt: Date.now(),
      iterations: 0,
      runs: [],
      skipped: 0,
      nextRunAt: 0,
      stopRequested: false,
    };
    jobs.set(job.id, job);
    tick(job);
    return job;
  }

  function parseStart(
    input: string,
    ctx: ExtensionContext,
  ): { ok: true; spec: NewJobSpec } | { ok: false; error: string } {
    const [intervalToken = "", ...restWords] = input.split(/\s+/);
    const intervalMs = parseInterval(intervalToken);
    if (intervalMs === undefined) {
      return {
        ok: false,
        error: `Invalid interval "${intervalToken}". Use s/m/h units, e.g. 30m, 1h, 0.5h.`,
      };
    }
    if (intervalMs < MIN_INTERVAL_MS) {
      return {
        ok: false,
        error: `Interval ${intervalToken} is too short; the minimum is ${MIN_INTERVAL_MS / 1000}s.`,
      };
    }

    // Keep the prompt verbatim after the interval, minus a leading model token.
    let remainder = input.slice(intervalToken.length).trimStart();
    let model: string | undefined;
    if (restWords.length > 1) {
      const token = restWords[0];
      const resolved = resolveModelToken(availableModels(ctx), token);
      if (resolved) {
        model = resolved;
        remainder = remainder.slice(token.length).trimStart();
      }
    }
    if (!remainder) {
      return { ok: false, error: `A prompt is required.\n\n${USAGE}` };
    }
    return {
      ok: true,
      spec: { intervalMs, intervalText: intervalToken, model, prompt: remainder },
    };
  }

  function listText(): string {
    if (jobs.size === 0) return `No cron jobs.\n\n${USAGE}`;
    const lines = [`⏱ ${jobs.size} cron job${jobs.size === 1 ? "" : "s"}`];
    for (const job of jobs.values()) {
      const run = activeRun(job);
      const last = lastFinishedRun(job);
      lines.push(
        "",
        `${job.id} — every ${job.intervalText}, model ${job.model ?? "inherit"}, ${job.iterations} run(s)${job.skipped ? `, ${job.skipped} skipped` : ""}`,
      );
      lines.push(`  prompt: ${trimText(job.prompt, 200).replace(/\n/g, " ")}`);
      if (run) {
        lines.push(
          `  now: ${statusIcon("running")} ${run.subagentId} ${formatDuration(Date.now() - run.startedAt)} (iteration #${run.iteration})`,
        );
      }
      if (last) {
        const head = (last.output ?? last.error ?? "").split("\n")[0];
        lines.push(
          `  last: ${statusIcon(last.status)} ${last.status} #${last.iteration} — ${head.slice(0, 120)}`,
        );
      }
      lines.push(
        job.stopRequested
          ? "  state: stopping after the current iteration"
          : `  next: in ${formatDuration(job.nextRunAt - Date.now())}`,
      );
    }
    return lines.join("\n");
  }

  const unsubscribeFinished = pi.events.on(SUBAGENT_FINISHED_CHANNEL, (data: unknown) => {
    const event = data as SubagentFinishedEvent | undefined;
    if (!event || shuttingDown) return;
    for (const job of jobs.values()) {
      const run = activeRun(job);
      if (!run || run.subagentId !== event.id) continue;
      run.status = event.status;
      run.endedAt = event.finishedAt;
      run.output = event.output;
      run.error = event.error;
      notifyMain(job, run);
      if (job.stopRequested) jobs.delete(job.id);
      refreshUi();
      return;
    }
  });

  pi.on("session_start", async (_event, ctx) => {
    lastCtx = ctx;
    shuttingDown = false;
    refreshUi();
  });

  pi.on("session_shutdown", async () => {
    shuttingDown = true;
    unsubscribeFinished();
    for (const job of jobs.values()) {
      if (job.timer) clearTimeout(job.timer);
      job.timer = undefined;
    }
    jobs.clear();
    refreshUi();
  });

  pi.registerCommand("cron", {
    description:
      "Run a prompt through a subagent on a fixed interval: /cron <interval> [<model>] <prompt>",
    handler: async (args, ctx) => {
      lastCtx = ctx;
      const input = args.trim();

      if (!input || input === "list") {
        ctx.ui.notify(listText(), "info");
        return;
      }
      if (input === "help" || input === "-h" || input === "--help") {
        ctx.ui.notify(USAGE, "info");
        return;
      }
      if (/^stop(?:\s|$)/.test(input)) {
        const ids = input.slice("stop".length).trim().split(/\s+/).filter(Boolean);
        const targets = ids.length === 0 ? [...jobs.keys()] : ids;
        if (targets.length === 0) {
          ctx.ui.notify("No cron jobs to stop.", "info");
          return;
        }
        const lines: string[] = [];
        for (const id of targets) {
          const job = jobs.get(id);
          if (!job) {
            lines.push(`✗ ${id} unknown`);
            continue;
          }
          const running = activeRun(job);
          stopJob(job);
          lines.push(
            running ? `◼ ${id} will stop after ${running.subagentId} finishes` : `◼ ${id} stopped`,
          );
        }
        ctx.ui.notify(lines.join("\n"), "info");
        return;
      }

      const parsed = parseStart(input, ctx);
      if (!parsed.ok) {
        ctx.ui.notify(parsed.error, "warning");
        return;
      }
      const job = startJob(parsed.spec, ctx);
      if (typeof job === "string") {
        ctx.ui.notify(job, "warning");
        return;
      }
      const first = job.runs[0];
      if (!first || !jobs.has(job.id)) {
        ctx.ui.notify(`✗ ${job.id} did not start; see the message above.`, "warning");
        return;
      }
      ctx.ui.notify(
        `⏱ ${job.id} started: every ${job.intervalText}${job.model ? `, ${job.model}` : ", inherit model"} → ${first.subagentId}`,
        "info",
      );
    },
  });

  function jobDetails(job: CronJob) {
    const last = lastFinishedRun(job);
    return {
      id: job.id,
      interval: job.intervalText,
      model: job.model ?? "inherit",
      prompt: job.prompt,
      runs: job.iterations,
      skipped: job.skipped,
      running: activeRun(job)?.subagentId,
      stopping: job.stopRequested,
      lastStatus: last?.status,
      lastOutput: last ? trimText(last.output ?? "", NOTIFY_OUTPUT_CAP) : undefined,
      nextRunAt: job.stopRequested ? undefined : job.nextRunAt,
    };
  }

  pi.registerTool({
    name: "cron_list",
    label: "Cron List",
    description:
      "List scheduled cron jobs: interval, model, iteration count, last result, and time until the next tick.",
    parameters: Type.Object({}),

    async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
      lastCtx = ctx;
      return {
        content: [{ type: "text", text: listText() }],
        details: { jobs: [...jobs.values()].map(jobDetails) },
      };
    },

    renderCall(_args, theme) {
      return new Text(theme.fg("toolTitle", theme.bold("cron_list ")), 0, 0);
    },

    renderResult(result, _options, theme) {
      const details = result.details as { jobs: { id: string; runs: number }[] } | undefined;
      if (!details?.jobs.length) return new Text(theme.fg("muted", "(no cron jobs)"), 0, 0);
      const lines = details.jobs.map(
        (j) => `${theme.fg("accent", j.id)} ${theme.fg("muted", `${j.runs} run(s)`)}`,
      );
      return new Text(lines.join("\n"), 0, 0);
    },
  });

  const JobIdsParam = Type.Array(Type.String({ description: 'Cron job id, e.g. "cron-1"' }), {
    minItems: 1,
  });

  pi.registerTool({
    name: "cron_stop",
    label: "Cron Stop",
    description:
      "Stop cron jobs. An iteration already running is allowed to finish; its report still arrives.",
    parameters: Type.Object({ ids: JobIdsParam }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      lastCtx = ctx;
      const stopped: string[] = [];
      const stopping: string[] = [];
      const unknown: string[] = [];
      for (const id of params.ids) {
        const job = jobs.get(id);
        if (!job) {
          unknown.push(id);
          continue;
        }
        const running = activeRun(job);
        stopJob(job);
        if (running) stopping.push(`${id} stops after ${running.subagentId} finishes`);
        else stopped.push(id);
      }
      const lines = [
        ...stopped.map((id) => `◼ ${id} stopped`),
        ...stopping.map((s) => `◼ ${s}`),
        ...unknown.map((id) => `✗ ${id} unknown (live: ${[...jobs.keys()].join(", ") || "none"})`),
      ];
      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: { stopped, stopping, unknown, isError: stopped.length + stopping.length === 0 },
      };
    },

    renderCall(args, theme) {
      return new Text(
        theme.fg("toolTitle", theme.bold("cron_stop ")) +
          theme.fg("warning", (args.ids ?? []).join(", ")),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as
        | { stopped: string[]; stopping: string[]; unknown: string[] }
        | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "(no output)", 0, 0);
      }
      const lines = [
        ...details.stopped.map(
          (id) =>
            `${theme.fg("muted", "◼")} ${theme.fg("accent", id)} ${theme.fg("muted", "stopped")}`,
        ),
        ...details.stopping.map((s) => `${theme.fg("muted", "◼")} ${theme.fg("warning", s)}`),
        ...details.unknown.map((id) => theme.fg("error", `✗ ${id} unknown`)),
      ];
      return new Text(lines.join("\n") || theme.fg("muted", "(nothing stopped)"), 0, 0);
    },
  });

  pi.registerTool({
    name: "cron_update",
    label: "Cron Update",
    description:
      'Change a cron job: its prompt, its interval (e.g. "30m", "2h"), or its model ("inherit" to stop pinning one).',
    parameters: Type.Object({
      id: Type.String({ description: 'Cron job id, e.g. "cron-1"' }),
      prompt: Type.Optional(
        Type.String({ description: "Replacement instructions for later iterations" }),
      ),
      interval: Type.Optional(Type.String({ description: 'New interval, e.g. "30m" or "2h"' })),
      model: Type.Optional(
        Type.String({
          description:
            'Full "provider/id", a bare model id, or "inherit". Resolved against the catalogue; unknown or ambiguous names are an error.',
        }),
      ),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      lastCtx = ctx;
      const job = jobs.get(params.id);
      if (!job) {
        const live = [...jobs.keys()].join(", ") || "none";
        return {
          content: [{ type: "text", text: `Unknown cron job ${params.id}. Live ids: ${live}.` }],
          details: { jobId: params.id, isError: true },
        };
      }

      const changed: string[] = [];
      if (params.prompt !== undefined) {
        const prompt = params.prompt.trim();
        if (!prompt) {
          return {
            content: [{ type: "text", text: "The prompt cannot be empty." }],
            details: { jobId: job.id, isError: true },
          };
        }
        job.prompt = prompt;
        changed.push("prompt");
      }
      if (params.interval !== undefined) {
        const intervalMs = parseInterval(params.interval.trim());
        if (intervalMs === undefined || intervalMs < MIN_INTERVAL_MS) {
          return {
            content: [
              {
                type: "text",
                text: `Invalid interval "${params.interval}". Use s/m/h, minimum ${MIN_INTERVAL_MS / 1000}s.`,
              },
            ],
            details: { jobId: job.id, isError: true },
          };
        }
        job.intervalMs = intervalMs;
        job.intervalText = params.interval.trim();
        if (!job.stopRequested) schedule(job, job.intervalMs);
        changed.push("interval");
      }
      if (params.model !== undefined) {
        const query = params.model.trim();
        if (query === "inherit") {
          job.model = undefined;
        } else {
          const resolved = resolveModel(availableModels(ctx), query);
          if (!resolved.ok) {
            return {
              content: [{ type: "text", text: resolved.error }],
              details: { jobId: job.id, isError: true },
            };
          }
          job.model = resolved.model;
        }
        changed.push("model");
      }

      refreshUi();
      const summary = [
        `⏱ ${job.id} updated: ${changed.length > 0 ? changed.join(", ") : "nothing changed"}`,
        `  every ${job.intervalText}, model ${job.model ?? "inherit"}`,
        `  prompt: ${trimText(job.prompt, 200).replace(/\n/g, " ")}`,
      ];
      return {
        content: [{ type: "text", text: summary.join("\n") }],
        details: { jobId: job.id, changed, isError: false },
      };
    },

    renderCall(args, theme) {
      const changed = [args.prompt && "prompt", args.interval && "interval", args.model && "model"]
        .filter(Boolean)
        .join(", ");
      return new Text(
        theme.fg("toolTitle", theme.bold("cron_update ")) +
          theme.fg("accent", args.id ?? "") +
          theme.fg("muted", changed ? ` (${changed})` : ""),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as
        | { jobId: string; changed?: string[]; isError?: boolean }
        | undefined;
      if (!details) {
        const text = result.content[0];
        return new Text(text?.type === "text" ? text.text : "(no output)", 0, 0);
      }
      if (details.isError) {
        const text = result.content[0];
        return new Text(theme.fg("error", text?.type === "text" ? text.text : "failed"), 0, 0);
      }
      return new Text(
        `${theme.fg("success", "✓")} ${theme.fg("accent", details.jobId)} ${theme.fg("muted", (details.changed ?? []).join(", "))}`,
        0,
        0,
      );
    },
  });
}
