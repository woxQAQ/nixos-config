// Reference other sessions from the prompt editor.
//
// - Typing `%` at the start of a token opens autocomplete over this project's
//   sessions (fuzzy match on name / first message / id). Selecting one inserts
//   a `%<id-prefix>` reference token.
// - On submit, every `%<id-prefix>` token is expanded inline into a
//   `<referenced-session>` block holding that session's compaction summary and
//   most recent user/assistant messages (budget-truncated).
// - `%%` escapes a literal percent sign.

import {
  SessionManager,
  type ExtensionAPI,
  type ExtensionContext,
  type SessionEntry,
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
// Per-reference budget for the expanded transcript excerpt.
const EXCERPT_BUDGET = 4_000;
const PER_MESSAGE_CAP = 600;
const MAX_MESSAGES = 30;

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

function messageText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content
    .filter(
      (block): block is { type: string; text: string } =>
        typeof block === "object" &&
        block !== null &&
        (block as { type?: unknown }).type === "text" &&
        typeof (block as { text?: unknown }).text === "string",
    )
    .map((block) => block.text)
    .join("\n");
}

type ExcerptLine = { label: string; text: string };

// Map a context entry to a labeled text line, or undefined when the entry
// carries no human-readable content for the excerpt.
function entryToLine(entry: SessionEntry): ExcerptLine | undefined {
  if (entry.type === "message") {
    // Older type stubs do not model system messages; treat the stored
    // message generically so both stub and runtime shapes typecheck.
    const message = entry.message as { role?: string; content?: unknown };
    if (message.role === "system" || message.role === "toolResult") return undefined;
    const text = messageText(message.content).trim();
    return text ? { label: message.role ?? "message", text } : undefined;
  }
  if (entry.type === "compaction") {
    return entry.summary ? { label: "summary", text: entry.summary } : undefined;
  }
  if (entry.type === "branch_summary") {
    return entry.summary ? { label: "branch-summary", text: entry.summary } : undefined;
  }
  if (entry.type === "custom_message") {
    const text = messageText(entry.content).trim();
    return text ? { label: entry.customType, text } : undefined;
  }
  return undefined;
}

// Walk the active branch from newest to oldest, collecting labeled message
// lines until the budget runs out, then restore chronological order.
function buildExcerpt(info: SessionInfo): string {
  const manager = SessionManager.open(info.path);
  const entries = manager.buildContextEntries();

  const lines: string[] = [];
  let budget = EXCERPT_BUDGET;
  for (let i = entries.length - 1; i >= 0 && lines.length < MAX_MESSAGES; i--) {
    const excerpt = entryToLine(entries[i]);
    if (!excerpt) continue;
    let { text } = excerpt;
    if (text.length > PER_MESSAGE_CAP) {
      text = `${text.slice(0, PER_MESSAGE_CAP)} …[truncated]`;
    }
    const line = `[${excerpt.label}] ${text}`;
    if (line.length > budget) {
      if (lines.length === 0) lines.push(line.slice(0, budget));
      break;
    }
    lines.push(line);
    budget -= line.length;
  }
  lines.reverse();

  const name = info.name ? ` name=${JSON.stringify(info.name)}` : "";
  return `<referenced-session id="${info.id}"${name} modified="${info.modified.toISOString()}">\n${lines.join("\n")}\n</referenced-session>`;
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
    const excerpts = new Map<string, string>();

    for (const token of tokens) {
      const matches = sessions.filter((s) => s.id !== currentSessionId && s.id.startsWith(token));
      if (matches.length === 0) {
        unresolved.push(`%${token}`);
        continue;
      }
      // list() sorts by recency, so the first match wins on a prefix collision.
      excerpts.set(token, buildExcerpt(matches[0]));
    }

    if (unresolved.length > 0) {
      ctx.ui.notify(
        `session-ref: no session matches ${unresolved.join(", ")} (left as-is)`,
        "warning",
      );
    }
    if (excerpts.size === 0) {
      return hadEscape
        ? { action: "transform", text: protectedText.replaceAll(ESCAPE_SENTINEL, "%") }
        : { action: "continue" };
    }

    const expanded = protectedText.replace(TOKEN_PATTERN, (raw, token: string) => {
      return excerpts.get(token) ?? raw;
    });
    return { action: "transform", text: expanded.replaceAll(ESCAPE_SENTINEL, "%") };
  });
}
