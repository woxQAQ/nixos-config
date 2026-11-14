import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { spawnSync } from "node:child_process";
import { resolve } from "node:path";

async function runLazygit(ctx: ExtensionContext, directory?: string): Promise<void> {
  if (ctx.mode !== "tui") {
    throw new Error("lazygit requires interactive TUI mode");
  }

  const targetDir = resolve(ctx.cwd, directory || ".");
  const git = spawnSync("git", ["rev-parse", "--git-dir"], {
    cwd: targetDir,
    stdio: "ignore",
  });
  if (git.error) {
    throw git.error;
  }
  if (git.status !== 0) {
    throw new Error(`Not a git repository: ${targetDir}`);
  }

  await ctx.ui.custom<void>((tui, _theme, _kb, done) => {
    tui.stop();
    try {
      process.stdout.write("\x1b[2J\x1b[H");
      const result = spawnSync("lazygit", [], {
        cwd: targetDir,
        stdio: "inherit",
        env: process.env,
      });
      if (result.error) {
        if (result.error.code === "ENOENT") {
          throw new Error("lazygit is not installed or is not available on PATH");
        }
        throw result.error;
      }
      if (result.signal) {
        throw new Error(`lazygit terminated by ${result.signal}`);
      }
      if (result.status !== 0) {
        throw new Error(`lazygit exited with code ${result.status}`);
      }
    } finally {
      tui.start();
      tui.requestRender(true);
    }
    done();
    return { render: () => [], invalidate: () => {} };
  });
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "lazygit",
    label: "lazygit",
    description: "Open lazygit for the user to interactively inspect and manage a Git repository.",
    executionMode: "sequential",
    parameters: Type.Object({
      directory: Type.Optional(Type.String({ description: "Git repo path (default: cwd)" })),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      await runLazygit(ctx, params.directory);
      return {
        content: [{ type: "text", text: "lazygit closed. Re-read Git state before continuing; the user may have changed the repository." }],
        details: undefined,
      };
    },
  });

  pi.registerCommand("lazygit", {
    description: "Open lazygit (usage: /lazygit [directory])",
    handler: async (args, ctx) => {
      try {
        await runLazygit(ctx, args.trim());
      } catch (error) {
        ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
      }
    },
  });
}
