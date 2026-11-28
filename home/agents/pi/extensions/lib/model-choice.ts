// Model-name resolution shared by the subagent and cron extensions.
//
// A user- or model-supplied name is resolved against the session catalogue. An
// unknown or ambiguous name is an error and never falls back to a default, so
// a typo cannot silently run on the wrong model. Every place that names a
// model must use these rules; they are the single source of truth.

import type { ExtensionContext } from "@earendil-works/pi-coding-agent";

export type ModelResolution = { ok: true; model: string } | { ok: false; error: string };

/** Every model usable in this session as "provider/id", sorted. */
export function availableModels(ctx: ExtensionContext): string[] {
  const scoped = ctx.scopedModels;
  const models = scoped.length > 0 ? scoped.map((s) => s.model) : ctx.modelRegistry.getAvailable();
  return models.map((m) => `${m.provider}/${m.id}`).sort();
}

/** Resolve a name against the catalogue: exact, unique bare id, then unique substring. */
export function resolveModel(available: string[], query: string): ModelResolution {
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

/**
 * Resolve a model named inside a free-form command line.
 *
 * Only "provider/id" queries and bare model ids qualify. A plain word in a
 * prompt must never be swallowed as a model just because it happens to be a
 * substring of some catalogue entry, so substring matching is deliberately
 * left out here — pass the full provider/id when unsure.
 */
export function resolveModelToken(available: string[], token: string): string | undefined {
  if (token.includes("/")) {
    const resolved = resolveModel(available, token);
    return resolved.ok ? resolved.model : undefined;
  }
  const lower = token.toLowerCase();
  const bare = available.filter((m) => m.split("/").pop()?.toLowerCase() === lower);
  return bare.length === 1 ? bare[0] : undefined;
}
