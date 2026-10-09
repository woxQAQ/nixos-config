import {
	AgentToolResult,
	ExtensionAPI,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import Type from "typebox";

import { execSync, spawnSync } from "node:child_process";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { closeSync, openSync, readFileSync, rmSync } from "node:fs";

interface TuicrOptions {
	directory?: string;
	revisions?: string;
}

function textResult(text: string): AgentToolResult<undefined> {
	return { content: [{ type: "text", text }], details: undefined };
}

// Run the tuicr TUI and return the exported review instructions.
// Returns an error string prefixed with "Error:" on failure, "" when the
// user exported nothing.
async function runTuicr(
	ctx: ExtensionContext,
	opts: TuicrOptions,): Promise<string> {
	try {
		execSync("command -v tuicr", { stdio: "ignore" });
	} catch {
		return "Error: tuicr is not installed. Install via: nix run github:agavra/tuicr";
	}
	const targetDir = opts.directory || ctx.cwd;
	try {
		execSync("git rev-parse --git-dir", {
			cwd: targetDir,
			stdio: "ignore",
		});
	} catch {
		return `Error: Not a git repository: ${targetDir}`;
	}
	if (!ctx.hasUI) {
		return "Error: tuicr requires interactive TUI mode";
	}

	// Build tuicr args
	const tuicrArgs: string[] = ["--stdout"];
	if (opts.revisions) {
		tuicrArgs.push("-r", opts.revisions);
	}

	// --stdout writes export to stdout; redirect to file so TUI uses stderr
	const outputFile = join(tmpdir(), `tuicr-${Date.now()}.md`);
	try {
		await ctx.ui.custom<number | null>((tui, _theme, _kb, done) => {
			tui.stop();
			process.stdout.write("\x1b[2J\x1b[H");

			const fd = openSync(outputFile, "w");
			try {
				const result = spawnSync("tuicr", tuicrArgs, {
					stdio: ["inherit", fd, "inherit"],
					env: process.env,
					cwd: targetDir,
				});
				tui.start();
				tui.requestRender(true);
				done(result.status);
			} finally {
				closeSync(fd);
			}

			return { render: () => [], invalidate: () => {} };
		});
	} catch {
		// ui.custom can throw on cancel
	}
	// Read captured instructions, stripping any terminal escape sequences
	// Covers CSI (ESC[..X), OSC (ESC]...ST), and ESC+char sequences
	const ansiRegex =
		/(?:\x1b\].*?(?:\x1b\\|\x07)|\x1b[\[()#;?]*[0-9;]*[A-Za-z@`\^\[\]{}|~=><]|\x9b[0-9;]*[A-Za-z@`\^\[\]{}|~=><])/g;
	let instructions = "";
	try {
		instructions = readFileSync(outputFile, "utf-8")
			.replace(ansiRegex, "")
			.trim();
	} catch {}
	try {
		rmSync(outputFile, { force: true });
	} catch {}

	return instructions;
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "tuicr",
		label: "tuicr",
		description: "Launch code review. Get feedback from the User.",
		parameters: Type.Object({
			directory: Type.Optional(
				Type.String({ description: "Git repo path (default: cwd)" }),
			),
			revisions: Type.Optional(
				Type.String({ description: "Commit range (e.g. HEAD~3..HEAD)" }),
			),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const result = await runTuicr(ctx, params);
			if (result.startsWith("Error:")) {
				return textResult(result);
			}
			if (result) {
				return textResult(`Review completed:\n${result}`);
			}
			return textResult(
				"Review completed. No instructions were exported. The user may paste instructions.",
			);
		},
	});

	// Proactive entry: /review [revisions] [directory]
	// Exported instructions are sent to the agent as a user message so it can
	// act on the feedback right away.
	pi.registerCommand("review", {
		description:
			"Launch tuicr code review (usage: /review [revisions] [directory])",
		handler: async (args, ctx) => {
			const [revisions, directory] = args.trim().split(/\s+/).filter(Boolean);
			const result = await runTuicr(ctx, { directory, revisions });
			if (result.startsWith("Error:")) {
				ctx.ui.notify(result.slice("Error: ".length), "error");
				return;
			}
			if (result) {
				pi.sendUserMessage(`Review completed:\n${result}`);
			} else {
				ctx.ui.notify(
					"Review completed. No instructions were exported.",
					"info",
				);
			}
		},
	});
}
