// clipsync: Wayland <-> X11 clipboard synchronization daemon.
//
// For Wayland compositors that run X11 apps through xwayland-satellite
// (niri, Hyprland, ...), where the satellite's clipboard bridge is
// incomplete: X-specific targets are dropped in translation and lazy
// selection owners fail to serve reads, so X11 apps (WeChat/QQ with
// QT_QPA_PLATFORM=xcb) cannot reliably paste from or to Wayland clients.
//
// clipsync is a thin orchestrator over battle-tested CLI tools:
//
//	X11 -> Wayland:  clipnotify exits      -> xclip reads  -> wl-copy
//	                 (relaunched in a loop, each exit = one selection event)
//	Wayland -> X11:  wl-paste --watch fires -> wl-paste reads -> xclip sets
//	                 (one watcher, any offer; xclip becomes the owner)
//
// A per-side "last synced" digest state machine prevents X -> W -> X echo
// loops. The watchers are the primary trigger; a slow per-side backstop poll
// recovers the rare event they miss (a wedged watcher, a restart gap, a
// failed push).
//
// Dependencies: xclip, clipnotify, wl-clipboard (wl-copy/wl-paste).
// Go port of https://github.com/ryan4yin/pyclipsync (MIT).
package main

import (
	"context"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"sync"
	"syscall"
	"time"
)

// Tunables, read once at startup. Values must be positive numbers; an
// invalid one logs a warning and falls back to the default.
var (
	// Recycle each watcher child every N seconds. A helper can wedge (stay
	// alive but stop delivering events), which would otherwise stall sync
	// until the whole service is restarted; bounding its lifetime makes it
	// self-heal.
	watchRecycle = envSeconds("WATCH_RECYCLE_SECONDS", 3600)

	// Timeout for a single clipboard helper call. The syncer lock is held
	// across these calls, so a hung helper stalls both directions. It is 6s
	// rather than 3s because a selection owner can be momentarily busy right
	// after a copy: WeChat (Qt/X11), for instance, can take over a second to
	// answer a background xclip read of a large image. With a shorter
	// timeout the offered type looks unreadable, the sync is skipped, and --
	// because nothing is recorded -- the same payload is read and retried on
	// every later event.
	clipboardTimeout = envSeconds("CLIPBOARD_TIMEOUT_SECONDS", 6)

	// Backstop interval. The watchers are the primary trigger and fire on
	// every change, so this poll only exists to recover the rare event they
	// miss. Keeping it coarse means an idle session does not read the whole
	// clipboard every few seconds.
	idlePoll = envSeconds("IDLE_POLL_SECONDS", 60)
)

const (
	// A clipboard owner can be briefly unresponsive right after a copy
	// (observed with WeChat on X11), so one empty read of an offered type is
	// not conclusive. Retry a couple of times with exponential backoff before
	// reporting the offer unreadable.
	readRetries    = 2
	readRetryDelay = 180 * time.Millisecond

	// Watcher retry policy: a watcher loop must survive helper failures
	// without dying (silent stall) or hot-looping (a fast respawn storm).
	// Each failure waits `delay`, which doubles up to the max; a healthy run
	// resets the backoff.
	watchBackoffMin = 200 * time.Millisecond
	watchBackoffMax = 30 * time.Second
)

var debug = os.Getenv("DEBUG") != ""

func debugf(format string, args ...any) {
	if debug {
		log.Printf("DEBUG "+format, args...)
	}
}

func envSeconds(name string, fallback float64) time.Duration {
	raw := os.Getenv(name)
	if raw == "" {
		return time.Duration(fallback * float64(time.Second))
	}
	value, err := strconv.ParseFloat(raw, 64)
	if err != nil || value <= 0 {
		log.Printf("%s=%q is not a positive number, using %v", name, raw, fallback)
		return time.Duration(fallback * float64(time.Second))
	}
	return time.Duration(value * float64(time.Second))
}

// Helpers the daemon cannot do without: wl-copy/wl-paste for the Wayland
// side, xclip for both reading and writing X. clipnotify is not required --
// without it X -> W still converges via the backstop poll (with a warning).
var requiredTools = []string{"wl-copy", "wl-paste", "xclip"}

func missingTools() []string {
	var missing []string
	for _, tool := range requiredTools {
		if _, err := exec.LookPath(tool); err != nil {
			missing = append(missing, tool)
		}
	}
	return missing
}

func main() {
	log.SetFlags(log.LstdFlags)

	if missing := missingTools(); len(missing) > 0 {
		log.Printf("missing required clipboard helpers in PATH: %v", missing)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	pool := newProcPool()
	syncer := newSyncer(pool)

	var wg sync.WaitGroup
	for _, watch := range []func(context.Context){
		func(ctx context.Context) { watchClipnotify(ctx, pool, syncer) },
		func(ctx context.Context) { watchWayland(ctx, pool, syncer) },
		func(ctx context.Context) { pollLoop(ctx, syncer) },
	} {
		wg.Add(1)
		go func() {
			defer wg.Done()
			watch(ctx)
		}()
	}

	log.Printf("clipsync started (DISPLAY=%s, WAYLAND_DISPLAY=%s)",
		os.Getenv("DISPLAY"), os.Getenv("WAYLAND_DISPLAY"))
	<-ctx.Done()
	log.Print("shutting down")
	stop()
	pool.cleanupWatchers()
	pool.cleanupOwners()
	wg.Wait()
}
