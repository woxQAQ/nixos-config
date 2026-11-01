import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const UPDATE_INTERVAL_MS = 250;

export default function (pi: ExtensionAPI) {
  let active: { startedAt: number; chars: number } | undefined;
  let timer: ReturnType<typeof setInterval> | undefined;

  function stop() {
    if (timer !== undefined) clearInterval(timer);
    timer = undefined;
    active = undefined;
  }

  function reset(ctx: ExtensionContext) {
    stop();
    if (ctx.hasUI) ctx.ui.setStatus("tps", undefined);
  }

  function render(ctx: ExtensionContext, output: number, estimated: boolean, suffix = "") {
    if (!active) return;
    const elapsedSeconds = (performance.now() - active.startedAt) / 1000;
    const prefix = estimated ? "~" : "";
    const rate =
      output > 0 && elapsedSeconds > 0
        ? `${prefix}${(output / elapsedSeconds).toFixed(1)}`
        : "--";
    ctx.ui.setStatus(
      "tps",
      `TPS ${rate} tok/s · out ${prefix}${output.toLocaleString()} · ${elapsedSeconds.toFixed(1)}s${suffix}`,
    );
  }

  pi.on("turn_start", (_event, ctx) => {
    stop();
    if (!ctx.hasUI) return;

    // Include the wait for output, but stop timing before tool execution.
    active = { startedAt: performance.now(), chars: 0 };
    render(ctx, 0, true);
    timer = setInterval(() => {
      if (active) render(ctx, Math.ceil(active.chars / 4), true);
    }, UPDATE_INTERVAL_MS);
    timer.unref();
  });

  pi.on("message_update", (event) => {
    if (!active) return;
    const update = event.assistantMessageEvent;
    switch (update.type) {
      case "text_delta":
      case "thinking_delta":
      case "toolcall_delta":
        // Usage can be absent or stale while streaming. Match Pi's chars/4 estimate.
        active.chars += update.delta.length;
        break;
    }
  });

  pi.on("message_end", (event, ctx) => {
    if (!active || event.message.role !== "assistant") return;
    const { usage, stopReason } = event.message;
    const interrupted = stopReason === "error" || stopReason === "aborted";
    // Interrupted streams may retain only the provider's initial usage snapshot.
    const estimated = interrupted || usage.output <= 0;
    const output = estimated ? Math.ceil(active.chars / 4) : usage.output;
    render(ctx, output, estimated, interrupted ? ` · ${stopReason}` : "");
    stop();
  });

  pi.on("agent_end", (_event, ctx) => {
    if (active) reset(ctx);
  });

  pi.on("session_start", (_event, ctx) => reset(ctx));
  pi.on("session_shutdown", (_event, ctx) => reset(ctx));
}
