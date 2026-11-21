import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { ImageContent, TextContent, UserMessage } from "@earendil-works/pi-ai";

interface RetryTarget {
  parentId: string;
  content: string | (TextContent | ImageContent)[];
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("retry", {
    description: "Rewind to the last user message and run it again",
    handler: async (_args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy; wait for it to settle before /retry", "warning");
        return;
      }

      // Walk the current branch backwards for the last real user message.
      let target: RetryTarget | undefined;
      const branch = ctx.sessionManager.getBranch();
      for (let i = branch.length - 1; i >= 0; i--) {
        const entry = branch[i];
        if (entry.type !== "message" || entry.message.role !== "user") continue;
        const message: UserMessage = entry.message;
        if (!entry.parentId) {
          // The first entry of a session has no parent to rewind onto.
          ctx.ui.notify("Cannot retry the session's first message", "warning");
          return;
        }
        target = { parentId: entry.parentId, content: message.content };
        break;
      }

      if (!target) {
        ctx.ui.notify("No user message to retry", "warning");
        return;
      }

      // Abandon the old attempt on a side branch, then resend the prompt.
      const result = await ctx.navigateTree(target.parentId, { summarize: false });
      if (result.cancelled) {
        ctx.ui.notify("Retry cancelled", "info");
        return;
      }

      const preview =
        typeof target.content === "string"
          ? target.content
          : target.content
              .filter((b): b is TextContent => b.type === "text")
              .map((b) => b.text)
              .join(" ");
      ctx.ui.notify(`Retrying: ${preview.slice(0, 80)}`, "info");
      pi.sendUserMessage(target.content);
    },
  });
}
