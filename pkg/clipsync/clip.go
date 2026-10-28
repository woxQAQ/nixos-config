// Helper processes & clipboard IO: every clipboard access on both sides goes
// through the CLI tools here, so the rest of the daemon deals only in kinds
// and bytes.
package main

import (
	"bytes"
	"context"
	"errors"
	"log"
	"os/exec"
	"strings"
	"sync"
	"syscall"
	"time"
)

// run executes a helper with the per-call timeout, returning its exit code
// and stdout. rc is -1 when the helper could not run to completion (missing
// binary, kill on timeout); callers treat any rc != 0 as "no data".
func run(name string, args ...string) (rc int, out []byte) {
	ctx, cancel := context.WithTimeout(context.Background(), clipboardTimeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, name, args...)
	out, err := cmd.Output()
	if ctx.Err() == context.DeadlineExceeded {
		// Distinguish a hung helper from an empty clipboard in the logs.
		log.Printf("%s timed out after %s", name, clipboardTimeout)
		return -1, nil
	}
	var exitErr *exec.ExitError
	switch {
	case err == nil:
		return 0, out
	case errors.As(err, &exitErr):
		return exitErr.ExitCode(), out
	default:
		debugf("%s failed: %v", name, err)
		return -1, nil
	}
}

// ---- Wayland side (wl-clipboard) -------------------------------------------

func wlTypes() map[string]struct{} {
	rc, out := run("wl-paste", "--list-types")
	if rc != 0 {
		return nil
	}
	return fieldsSet(string(out))
}

func wlRead(mime string) []byte {
	rc, out := run("wl-paste", "--type", mime)
	if rc == 0 && len(out) > 0 {
		return out
	}
	return nil
}

func wlCopy(pool *procPool, mime string, data []byte) bool {
	// wl-copy appends exactly one trailing newline to piped text/* input.
	// Strip one first so text always lands on the Wayland side with exactly
	// one trailing newline.
	if strings.HasPrefix(mime, "text/") && bytes.HasSuffix(data, []byte("\n")) {
		data = data[:len(data)-1]
	}
	return pool.spawnOwner([]string{"wl-copy", "--type", mime}, data)
}

// ---- X11 side (xclip) -------------------------------------------------------

func xTargets() map[string]struct{} {
	rc, out := run("xclip", "-selection", "clipboard", "-t", "TARGETS", "-o")
	if rc != 0 {
		return nil
	}
	// Some owners NUL-separate the target list.
	return fieldsSet(strings.ReplaceAll(string(out), "\x00", " "))
}

func xRead(target string) []byte {
	rc, out := run("xclip", "-selection", "clipboard", "-t", target, "-o")
	if rc == 0 && len(out) > 0 {
		return out
	}
	return nil
}

func xSet(pool *procPool, target string, data []byte) bool {
	return pool.spawnOwner([]string{"xclip", "-selection", "clipboard", "-t", target}, data)
}

func fieldsSet(s string) map[string]struct{} {
	set := make(map[string]struct{})
	for _, f := range strings.Fields(s) {
		set[f] = struct{}{}
	}
	return set
}

// ---- Process pool -----------------------------------------------------------

// procPool tracks the helper processes we spawn so they can be reaped at
// shutdown. Both kinds are reparented and would outlive us:
//
//	owners   -- wl-copy/xclip fork a child that keeps serving the selection.
//	            Each is started in its own session, so we remember the process
//	            group and kill the whole group.
//	watchers -- wl-paste --watch / clipnotify children we read events from;
//	            terminated directly.
type procPool struct {
	mu       sync.Mutex
	owners   map[int]struct{}
	watchers map[*exec.Cmd]struct{}
}

func newProcPool() *procPool {
	return &procPool{
		owners:   make(map[int]struct{}),
		watchers: make(map[*exec.Cmd]struct{}),
	}
}

// spawnOwner runs a clipboard-owner command and remembers its process group.
//
// wl-copy and xclip fork a child that keeps serving the selection after the
// parent exits; that child outlives us and would keep owning the clipboard
// with stale data. Running it in its own session lets cleanupOwners kill the
// whole group on shutdown.
func (p *procPool) spawnOwner(argv []string, data []byte) bool {
	cmd := exec.Command(argv[0], argv[1:]...)
	cmd.Stdin = bytes.NewReader(data)
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
	if err := cmd.Start(); err != nil {
		debugf("%s failed: %v", argv[0], err)
		return false
	}
	done := make(chan error, 1)
	go func() { done <- cmd.Wait() }()
	select {
	case err := <-done:
		if err != nil {
			debugf("%s exited with %v", argv[0], err)
			return false
		}
	case <-time.After(clipboardTimeout):
		// Kill the whole group: the direct child may already have forked the
		// owner child that holds the selection.
		killGroup(cmd.Process.Pid, syscall.SIGKILL)
		<-done
		log.Printf("%s did not return within %s", argv[0], clipboardTimeout)
		return false
	}
	p.pruneOwners()
	p.mu.Lock()
	p.owners[cmd.Process.Pid] = struct{}{}
	p.mu.Unlock()
	return true
}

// pruneOwners forgets owner groups that no longer exist. A recorded pgid can
// be recycled by the kernel once its owner exits, so keeping dead entries
// around risks signalling an unrelated group later.
func (p *procPool) pruneOwners() {
	p.mu.Lock()
	defer p.mu.Unlock()
	for pgid := range p.owners {
		if !groupAlive(pgid) {
			delete(p.owners, pgid)
		}
	}
}

// cleanupOwners kills the clipboard-owner process groups we spawned (best
// effort).
func (p *procPool) cleanupOwners() {
	p.mu.Lock()
	pgids := make([]int, 0, len(p.owners))
	for pgid := range p.owners {
		pgids = append(pgids, pgid)
	}
	p.owners = make(map[int]struct{})
	p.mu.Unlock()
	for _, pgid := range pgids {
		if groupAlive(pgid) {
			killGroup(pgid, syscall.SIGTERM)
		}
	}
}

func (p *procPool) registerWatcher(cmd *exec.Cmd) {
	p.mu.Lock()
	p.watchers[cmd] = struct{}{}
	p.mu.Unlock()
}

func (p *procPool) unregisterWatcher(cmd *exec.Cmd) {
	p.mu.Lock()
	delete(p.watchers, cmd)
	p.mu.Unlock()
}

// cleanupWatchers terminates the watcher children we spawned (best effort).
// Under systemd the cgroup kill covers this, but not when run by hand.
func (p *procPool) cleanupWatchers() {
	p.mu.Lock()
	procs := make([]*exec.Cmd, 0, len(p.watchers))
	for cmd := range p.watchers {
		procs = append(procs, cmd)
	}
	p.watchers = make(map[*exec.Cmd]struct{})
	p.mu.Unlock()
	for _, cmd := range procs {
		terminate(cmd)
	}
}

// terminate stops a child, escalating to SIGKILL; never blocks for long.
func terminate(cmd *exec.Cmd) {
	if cmd.Process == nil {
		return
	}
	if err := cmd.Process.Signal(syscall.SIGTERM); err != nil {
		return
	}
	done := make(chan struct{})
	go func() {
		cmd.Wait()
		close(done)
	}()
	select {
	case <-done:
	case <-time.After(2 * time.Second):
		cmd.Process.Kill()
		<-done
	}
}

func killGroup(pgid int, sig syscall.Signal) {
	// A group we created may already be gone; nothing to do then.
	_ = syscall.Kill(-pgid, sig)
}

// groupAlive reports whether a process group with this id still exists.
func groupAlive(pgid int) bool {
	err := syscall.Kill(-pgid, 0)
	return err == nil || err == syscall.EPERM
}
