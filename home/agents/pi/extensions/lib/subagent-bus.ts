// Contract between extensions that drive subagents and the extension that owns
// them (`subagent.ts`).
//
// Pi loads every extension through its own jiti registry, so two extensions
// cannot share module-level state — importing `subagent.ts` from `cron.ts`
// would evaluate it twice and hand back a second, empty registry. The live
// subagent registry is therefore reached over the shared event bus: a
// requester emits `SUBAGENT_SERVICE_CHANNEL` with a reply callback, and
// `subagent.ts` answers with a handle on its registry. Terminal states are
// published on `SUBAGENT_FINISHED_CHANNEL`.
//
// Only plain data and callbacks cross this boundary; nothing here holds state.

import type { ExtensionContext } from "@earendil-works/pi-coding-agent";

export const SUBAGENT_SERVICE_CHANNEL = "subagent:service:request";
export const SUBAGENT_FINISHED_CHANNEL = "subagent:finished";

/** One subagent to spawn. `model` is resolved against the catalogue by the owner. */
export interface SubagentSpec {
  task: string;
  /** Full "provider/id"; omitted means "inherit the dispatching session model". */
  model?: string;
  /** Relative to the session cwd. */
  cwd?: string;
}

/** A live subagent, as described to the requester. */
export interface SubagentCreatedSummary {
  id: string;
  model: string;
  task: string;
  cwd: string;
}

export interface SubagentCreateResult {
  created: SubagentCreatedSummary[];
  /** One message per spec that could not be spawned. */
  failures: string[];
}

/** The live subagent registry, as seen from another extension. */
export interface SubagentService {
  create(specs: SubagentSpec[], ctx: ExtensionContext): SubagentCreateResult;
}

/** Reply callback carried by `SUBAGENT_SERVICE_CHANNEL`. */
export type SubagentServiceReply = (service: SubagentService | undefined) => void;

/** Every state a subagent can rest in; "running" is not terminal. */
export type SubagentEndStatus = "completed" | "failed" | "aborted" | "destroyed";

export interface SubagentUsage {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  turns: number;
}

/** Published once per subagent when it reaches a terminal state. */
export interface SubagentFinishedEvent {
  id: string;
  task: string;
  status: SubagentEndStatus;
  /** Last assistant text; empty when the subagent produced none. */
  output: string;
  error?: string;
  usage: SubagentUsage;
  startedAt: number;
  finishedAt: number;
}
