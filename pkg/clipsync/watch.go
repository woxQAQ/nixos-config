// Watchers: the primary change triggers for both directions, plus the slow
// backstop poll that recovers whatever they miss.
package main

import (
	"bufio"
	"context"
	"log"
	"os/exec"
	"sync/atomic"
	"time"
)

// watchLoop runs once() forever, backing off only when it reports a failure.
//
// once() returns true after a healthy run (an event was handled, or the
// helper was recycled on schedule) and false when it failed. Only failures
// back off, so a one-shot helper that legitimately exits after every event
// (clipnotify) is relaunched immediately instead of being throttled as if it
// kept failing. A watcher must never die silently either, so a failure is
// retried with capped backoff rather than escaping the loop.
func watchLoop(ctx context.Context, name string, once func() bool) {
	delay := watchBackoffMin
	for ctx.Err() == nil {
		healthy := once()
		if healthy {
			delay = watchBackoffMin
			continue
		}
		debugf("%s watcher failed, retrying in %s", name, delay)
		select {
		case <-ctx.Done():
			return
		case <-time.After(delay):
		}
		delay = min(delay*2, watchBackoffMax)
	}
}

// readAsync runs a state read off the watcher goroutine.
//
// A read can take a while (a retry, or a clipboardTimeout on a hung owner),
// so doing it in the watcher would delay the watcher's relaunch and widen
// its registration gap -- changes in that gap are missed. The syncer lock
// serializes the concurrent reads.
func readAsync(fn func()) {
	go fn()
}

// watchClipnotify forwards each X11 selection owner change (X -> W).
//
// clipnotify is a one-shot trigger by design: it blocks until the next
// CLIPBOARD/PRIMARY owner-change event and then exits silently (no output,
// no flags). Its intended usage is a relaunch loop
// (`while clipnotify; do ...; done`), so we do exactly that: every exit
// means "something changed", and we re-read the X state. PRIMARY
// (click-selection) changes also trigger it, but the digest-based dedup in
// onXChange filters those out.
func watchClipnotify(ctx context.Context, pool *procPool, syncer *syncer) {
	if _, err := exec.LookPath("clipnotify"); err != nil {
		log.Printf("clipnotify not found in PATH; X -> W sync relies on the backstop poll")
		return
	}
	watchLoop(ctx, "clipnotify", func() bool {
		cmd := exec.Command("clipnotify")
		if err := cmd.Start(); err != nil {
			log.Printf("clipnotify failed to start: %v", err)
			return false
		}
		pool.registerWatcher(cmd)
		done := make(chan error, 1)
		go func() { done <- cmd.Wait() }()
		var waitErr error
		recycled := false
		select {
		case waitErr = <-done:
		case <-time.After(watchRecycle):
			// No X selection change for a whole interval: just recycle.
			recycled = true
		case <-ctx.Done():
		}
		pool.unregisterWatcher(cmd)
		if cmd.ProcessState == nil {
			terminate(cmd)
			<-done
		}
		switch {
		case ctx.Err() != nil || recycled:
			return true
		case waitErr != nil:
			log.Printf("clipnotify exited with %v", waitErr)
			return false
		default:
			readAsync(syncer.onXChange)
			return true
		}
	})
}

// watchWayland forwards each Wayland selection change (W -> X).
//
// `wl-paste --watch echo` runs `echo` on every selection change (echo
// ignores stdin and prints one newline -- a pure change signal); with no
// --type, wl-paste falls back to any offered type, so a single watcher
// covers every offer instead of one watcher per mime type. The read runs off
// this goroutine (see readAsync), so the watcher keeps consuming offers.
//
// The watch child is recycled every watchRecycle seconds so a wedged watcher
// cannot silently stall W -> X sync.
func watchWayland(ctx context.Context, pool *procPool, syncer *syncer) {
	watchLoop(ctx, "wl-paste --watch", func() bool {
		cmd := exec.Command("wl-paste", "--watch", "echo")
		stdout, err := cmd.StdoutPipe()
		if err != nil {
			log.Printf("wl-paste stdout pipe failed: %v", err)
			return false
		}
		if err := cmd.Start(); err != nil {
			log.Printf("wl-paste failed to start: %v", err)
			return false
		}
		pool.registerWatcher(cmd)

		var recycled atomic.Bool
		recycler := time.AfterFunc(watchRecycle, func() {
			recycled.Store(true)
			cmd.Process.Kill()
		})
		// Unblock the scanner when the daemon shuts down.
		stopped := make(chan struct{})
		go func() {
			select {
			case <-ctx.Done():
				cmd.Process.Kill()
			case <-stopped:
			}
		}()

		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			readAsync(syncer.onWChange)
		}
		recycler.Stop()
		close(stopped)
		cmd.Wait()
		pool.unregisterWatcher(cmd)
		return recycled.Load()
	})
}

// pollLoop is the slow backstop for the events the watchers miss.
//
// The watchers fire on every change, so this is only a safety net: a wedged
// watcher (until its recycle), the small registration gap when a watcher
// restarts, or a push that failed with no later event to retry it. Reading
// first syncs whatever is already on the clipboards at startup. The on*Change
// handlers are digest-deduped, so a poll with nothing changed is a cheap
// no-op.
func pollLoop(ctx context.Context, syncer *syncer) {
	for ctx.Err() == nil {
		syncer.onXChange()
		syncer.onWChange()
		select {
		case <-ctx.Done():
			return
		case <-time.After(idlePoll):
		}
	}
}
