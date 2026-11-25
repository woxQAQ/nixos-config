// Reference other sessions from the prompt editor.
//
// - Typing `%` at the start of a token opens autocomplete over this project's
//   sessions (fuzzy match on name / first message / id). Selecting one inserts
//   a `%<id-prefix>` reference token.
// - On submit, every `%<id-prefix>` token is expanded into a
//   `<referenced-session>` block pointing at the session's transcript file,
//   so the model reads the path itself instead of us inlining the excerpt.
// - `%%` escapes a literal percent sign.

import {
  SessionManager,
  type ExtensionAPI,
  type ExtensionContext,
  type SessionInfo,
} from "@earendil-works/pi-coding-agent";
import {
  type AutocompleteItem,
  type AutocompleteProvider,
  type AutocompleteSuggestions,
  fuzzyFilter,
} from "@earendil-works/pi-tui";

const MAX_SUGGESTIONS = 20;
const ID_PREFIX_LENGTH = 8;
// How fresh the cached session list must be before we re-scan the session dir.
const CACHE_TTL_MS = 10_000;

const ESCAPE_SENTINEL = "\u0000PCT\u0000";
const TOKEN_PATTERN = /%([0-9a-fA-F-]{4,36})/g;

type SessionCache = {
  cwd: string;
  fetchedAt: number;
  sessions: SessionInfo[];
};

function extractRefToken(textBeforeCursor: string): string | undefined {
  const match = textBeforeCursor.match(/(?:^|\s)%([^\s%]*)$/);
  return match?.[1];
}

function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function toItem(session: SessionInfo): AutocompleteItem {
  const shortId = session.id.slice(0, ID_PREFIX_LENGTH);
  const title = session.name || session.firstMessage;
  return {
    value: `%${shortId}`,
    label: `%${shortId}`,
    description: `[${formatDate(session.modified)}] ${title}`,
  };
}

function filterSessions(sessions: SessionInfo[], query: string): AutocompleteItem[] {
  if (!query.trim()) {
    return sessions.slice(0, MAX_SUGGESTIONS).map(toItem);
  }
  return fuzzyFilter(
    sessions,
    query,
    (s) => `${s.id.slice(0, ID_PREFIX_LENGTH)} ${s.name ?? ""} ${s.firstMessage}`,
  )
    .slice(0, MAX_SUGGESTIONS)
    .map(toItem);
}

// Expand a reference to a pointer at the session's transcript file. The
// transcript is a JSONL file (one entry per line, e.g. message/compaction
// entries); the model decides how much of it to read.
function buildReference(info: SessionInfo): string {
  const name = info.name ? ` name=${JSON.stringify(info.name)}` : "";
  const title = info.name || info.firstMessage;
  return [
    `<referenced-session id="${info.id}"${name} modified="${info.modified.toISOString()}">`,
    `The user referenced a previous session: "${title}".`,
    `Its transcript is stored as JSONL at: ${info.path}`,
    "Use the read tool on that path to inspect it.",
    `</referenced-session>`,
  ].join("\n");
}

export default function (pi: ExtensionAPI): void {
  let cache: SessionCache | undefined;
  let currentSessionId: string | undefined;

  async function getSessions(ctx: ExtensionContext, force = false): Promise<SessionInfo[]> {
    const fresh = cache && cache.cwd === ctx.cwd && Date.now() - cache.fetchedAt < CACHE_TTL_MS;
    if (!force && fresh && cache) {
      return cache.sessions;
    }
    const sessions = await SessionManager.list(ctx.cwd);
    cache = { cwd: ctx.cwd, fetchedAt: Date.now(), sessions };
    return sessions;
  }

  pi.on("session_start", async (_event, ctx) => {
    currentSessionId = ctx.sessionManager.getSessionId();
    cache = undefined;
    void getSessions(ctx);

    ctx.ui.addAutocompleteProvider((current): AutocompleteProvider => {
      return {
        // The editor only opens autocomplete for default triggers (@, #)
        // plus characters declared here; without this % never fires.
        triggerCharacters: ["%"],

        async getSuggestions(
          lines,
          cursorLine,
          cursorCol,
          options,
        ): Promise<AutocompleteSuggestions | null> {
          const currentLine = lines[cursorLine] ?? "";
          const token = extractRefToken(currentLine.slice(0, cursorCol));
          if (token === undefined) {
            return current.getSuggestions(lines, cursorLine, cursorCol, options);
          }

          const sessions = (await getSessions(ctx)).filter((s) => s.id !== currentSessionId);
          if (options.signal.aborted || sessions.length === 0) {
            return current.getSuggestions(lines, cursorLine, cursorCol, options);
          }

          const items = filterSessions(sessions, token);
          if (items.length === 0) {
            return current.getSuggestions(lines, cursorLine, cursorCol, options);
          }

          return { items, prefix: `%${token}` };
        },

        applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
          return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
        },

        shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
          return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
        },
      };
    });
  });

  pi.on("input", async (event, ctx) => {
    if (!event.text.includes("%")) {
      return { action: "continue" };
    }

    // Protect %% escapes before scanning for reference tokens.
    const hadEscape = event.text.includes("%%");
    const protectedText = event.text.replaceAll("%%", ESCAPE_SENTINEL);
    const tokens = [...new Set([...protectedText.matchAll(TOKEN_PATTERN)].map((m) => m[1]))];
    if (tokens.length === 0) {
      // No references; still collapse escapes so %% renders as a single %.
      return hadEscape
        ? { action: "transform", text: protectedText.replaceAll(ESCAPE_SENTINEL, "%") }
        : { action: "continue" };
    }

    const sessions = await getSessions(ctx, true);
    const unresolved: string[] = [];
    const references = new Map<string, string>();

    for (const token of tokens) {
      const matches = sessions.filter((s) => s.id !== currentSessionId && s.id.startsWith(token));
      if (matches.length === 0) {
        unresolved.push(`%${token}`);
        continue;
      }
      // list() sorts by recency, so the first match wins on a prefix collision.
      references.set(token, buildReference(matches[0]));
    }

    if (unresolved.length > 0) {
      ctx.ui.notify(
        `session-ref: no session matches ${unresolved.join(", ")} (left as-is)`,
        "warning",
      );
    }
    if (references.size === 0) {
      return hadEscape
        ? { action: "transform", text: protectedText.replaceAll(ESCAPE_SENTINEL, "%") }
        : { action: "continue" };
    }

    const expanded = protectedText.replace(TOKEN_PATTERN, (raw, token: string) => {
      return references.get(token) ?? raw;
    });
    return { action: "transform", text: expanded.replaceAll(ESCAPE_SENTINEL, "%") };
  });
}
