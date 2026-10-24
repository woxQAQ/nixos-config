import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";

/** Add whitespace without rewriting numeric literals, duplicate keys, or string escapes. */
function prettyJsonLine(line: string, theme: Theme): string {
  const source = line.trim();
  if (!source.startsWith("{") && !source.startsWith("[")) return line;
  try {
    JSON.parse(source);
  } catch {
    // Plain text and truncated JSON remain readable in their original form.
    return line;
  }

  const tokens = source.match(/"(?:[^"\\]|\\.)*"|[^\s{}\[\],:]+|[{}\[\],:]/g)!;
  const parts: string[] = [];
  let depth = 0;
  const newline = () => parts.push(`\n${"  ".repeat(depth)}`);

  for (let index = 0; index < tokens.length; index++) {
    const token = tokens[index];
    switch (token) {
      case "{":
      case "[":
        parts.push(token);
        depth++;
        if (tokens[index + 1] !== "}" && tokens[index + 1] !== "]") newline();
        break;
      case "}":
      case "]":
        depth--;
        if (tokens[index - 1] !== "{" && tokens[index - 1] !== "[") newline();
        parts.push(token);
        break;
      case ",":
        parts.push(token);
        newline();
        break;
      case ":":
        parts.push(": ");
        break;
      default:
        parts.push(token);
    }
  }
  return parts
    .join("")
    .replace(/"(?:[^"\\]|\\.)*"|[^\s{}\[\],:]+|[{}\[\],:]/g, (token, offset, text) => {
      if (token.startsWith('"')) {
        const isKey = text
          .slice(offset + token.length)
          .trimStart()
          .startsWith(":");
        return theme.fg(isKey ? "syntaxVariable" : "syntaxString", token);
      }
      if (/^[{}\[\],:]$/.test(token)) return theme.fg("syntaxPunctuation", token);
      if (/^(true|false|null)$/.test(token)) return theme.fg("syntaxKeyword", token);
      return theme.fg("syntaxNumber", token);
    });
}

export default function (pi: ExtensionAPI) {
  pi.registerToolRenderer((toolName, next) => {
    const original = next();
    if (toolName !== "codemode" || !original?.renderResult) return original;
    const renderResult = original.renderResult;

    return {
      ...original,
      renderResult(result, options, theme, context) {
        if (options.isPartial) return renderResult(result, options, theme, context);
        // Format a presentation-only copy; transcript and model-facing content stay intact.
        const content = result.content.map((block) =>
          block.type === "text"
            ? {
                ...block,
                text: block.text
                  .split("\n")
                  .map((line) => prettyJsonLine(line, theme))
                  .join("\n"),
              }
            : block,
        );
        return renderResult({ ...result, content }, options, theme, context);
      },
    };
  });
}
