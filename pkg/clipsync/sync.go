// Content model and the sync state machine: what a clipboard payload is,
// which type wins when several are offered, and how the two directions
// decide whether a change needs pushing.
package main

import (
	"crypto/sha256"
	"encoding/hex"
	"log"
	"strings"
	"sync"
	"time"
)

// X11 atoms.
const (
	xURI        = "text/uri-list"
	xGnomeFiles = "x-special/gnome-copied-files"
	xPNG        = "image/png"
	xJPEG       = "image/jpeg"
	xHTML       = "text/html"
	xUTF8       = "UTF8_STRING"
	xString     = "STRING"
	xPlain      = "text/plain"
)

// Wayland mime types. Text comes as text/plain or the charset-qualified form
// (GTK/Qt/Chromium use the latter); read both, prefer UTF-8.
const (
	wText     = "text/plain"
	wTextUTF8 = "text/plain;charset=utf-8"
	wPNG      = "image/png"
	wJPEG     = "image/jpeg"
	wHTML     = "text/html"
	wURI      = "text/uri-list"
)

// Human-readable side names for logs and diagnostics.
const (
	xLabel = "X11 clipboard"
	wLabel = "Wayland clipboard"
)

// kind -> target/mime per direction (uri-list always maps to text/uri-list
// on both sides; that is what WeChat and QQ read for pasted file/image
// links).
var wKindMimes = map[string]string{
	"text": wText,
	"uri":  wURI,
	"png":  wPNG,
	"jpeg": wJPEG,
	"html": wHTML,
}

var xKindTargets = map[string]string{
	"text": xUTF8,
	"uri":  xURI,
	"png":  xPNG,
	"jpeg": xJPEG,
	"html": xHTML,
}

// byteExactKinds survive xclip and wl-copy byte-exact (unlike text/*, which
// wl-copy reshapes with a trailing newline). After a successful push these
// need no destination readback: the pushed state *is* the destination state,
// so reading it back would just re-transfer the whole image.
var byteExactKinds = map[string]struct{}{"png": {}, "jpeg": {}}

// priority is one content kind: the target/mime spellings it can appear
// under, in preference order, plus an optional payload normalizer.
type priority struct {
	kind      string
	types     []string
	transform func([]byte) []byte
}

// Read priority per side, highest first. X has two URI spellings: GNOME file
// copies and QQ stickers use x-special/gnome-copied-files, everyone else
// text/uri-list.
var xPriority = []priority{
	{"png", []string{xPNG}, nil},
	{"jpeg", []string{xJPEG}, nil},
	{"uri", []string{xGnomeFiles, xURI}, normalizeURI},
	{"html", []string{xHTML}, nil},
	{"text", []string{xUTF8, xPlain, xString}, nil},
}

var wPriority = []priority{
	{"png", []string{wPNG}, nil},
	{"jpeg", []string{wJPEG}, nil},
	{"uri", []string{wURI}, normalizeURI},
	{"html", []string{wHTML}, nil},
	{"text", []string{wTextUTF8, wText}, nil},
}

// Types we can read, derived from the priorities so they cannot drift. Used
// only by the unreadable-offer diagnostic, so an unrelated MIME does not
// warn.
var xSupported = supportedTypes(xPriority)
var wSupported = supportedTypes(wPriority)

func supportedTypes(prios []priority) map[string]struct{} {
	set := make(map[string]struct{})
	for _, p := range prios {
		for _, t := range p.types {
			set[t] = struct{}{}
		}
	}
	return set
}

// normalizeURI normalizes an uri-list / gnome-copied-files payload: it drops
// the leading 'copy'/'cut' action header that x-special/gnome-copied-files
// carries, and rewrites bare absolute paths to file:// URIs. It returns nil
// when nothing usable remains.
func normalizeURI(data []byte) []byte {
	var out []string
	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		switch {
		case line == "" || line == "copy" || line == "cut":
			continue
		case strings.HasPrefix(line, "/"):
			out = append(out, "file://"+line)
		default:
			out = append(out, line)
		}
	}
	if len(out) == 0 {
		return nil
	}
	return []byte(strings.Join(out, "\n") + "\n")
}

// state is one clipboard payload: what it is, its bytes, and a digest for
// dedup. Built with stateOf so the digest is always derived from the data
// (never stale). The syncer keeps lastX/lastW around and compares their
// digests later.
type state struct {
	kind   string
	data   []byte
	digest string
}

func stateOf(kind string, data []byte) *state {
	sum := sha256.Sum256(data)
	return &state{kind: kind, data: data, digest: hex.EncodeToString(sum[:])}
}

// readState returns the highest-priority readable state, or nil.
//
// An owner can be briefly unresponsive right after a copy, so a scan that
// finds an offered type but no data is retried a couple of times with
// exponential backoff before giving up. An offer with no type we handle is
// not retried.
func readState(offered map[string]struct{}, read func(string) []byte, prio []priority, supported map[string]struct{}) *state {
	if !intersects(offered, supported) {
		return nil
	}
	readOnce := func() *state {
		for _, p := range prio {
			for _, mime := range p.types {
				if _, ok := offered[mime]; !ok {
					continue
				}
				data := read(mime)
				if len(data) > 0 && p.transform != nil {
					data = p.transform(data)
				}
				if len(data) > 0 {
					return stateOf(p.kind, data)
				}
			}
		}
		return nil
	}
	delay := readRetryDelay
	for attempt := 0; attempt <= readRetries; attempt++ {
		if attempt > 0 {
			time.Sleep(delay)
			delay *= 2
		}
		if st := readOnce(); st != nil {
			return st
		}
	}
	return nil
}

// warnUnreadable warns when a supported type is offered but cannot be read.
//
// Reading is best-effort: wl-paste/xclip can return nothing even though the
// selection advertises a type we handle -- e.g. a client that keeps
// selection ownership but refuses to serve a background/data-control reader
// (observed with Chromium on Wayland). Without this the miss is silent: no
// sync happens and no log line says why.
//
// Logged on every read: in steady state that is at most one per backstop
// poll (idlePoll, 60s), which is acceptable and shows the problem is still
// ongoing.
func warnUnreadable(side string, offered, supported map[string]struct{}) {
	var stuck []string
	for t := range offered {
		if _, ok := supported[t]; ok {
			stuck = append(stuck, t)
		}
	}
	if len(stuck) > 0 {
		log.Printf("%s: %d supported type(s) offered but unreadable, sync skipped: %s",
			side, len(stuck), strings.Join(stuck, " "))
	}
}

func intersects(a, b map[string]struct{}) bool {
	for k := range a {
		if _, ok := b[k]; ok {
			return true
		}
	}
	return false
}

func xState() *state {
	targets := xTargets()
	debugf("read X: %d targets", len(targets))
	st := readState(targets, xRead, xPriority, xSupported)
	if st == nil {
		warnUnreadable(xLabel, targets, xSupported)
	}
	return st
}

func wState() *state {
	types := wlTypes()
	debugf("read W: %d types", len(types))
	st := readState(types, wlRead, wPriority, wSupported)
	if st == nil {
		warnUnreadable(wLabel, types, wSupported)
	}
	return st
}

// destinationAfterPush is the state to record for the side that just
// received a push. Binary mimes survive both helpers byte-exact, so the
// pushed state *is* the destination and the readback (which would
// re-transfer the whole image) is skipped. Text may be reshaped by wl-copy,
// so it is measured.
func destinationAfterPush(st *state, readback func() *state) *state {
	if _, ok := byteExactKinds[st.kind]; ok {
		return st
	}
	if rb := readback(); rb != nil {
		return rb
	}
	return st
}

// syncer serializes both directions and remembers the last state known to
// be present on each side (digest form) for dedup.
type syncer struct {
	pool         *procPool
	mu           sync.Mutex
	lastX, lastW *state
}

func newSyncer(pool *procPool) *syncer {
	return &syncer{pool: pool}
}

// The state read, the dedup decision and the push are one atomic step under
// the lock: reading outside the lock lets a goroutine capture a stale
// clipboard, then pass a stale dedup check and push old data, which is what
// causes X -> W -> X echo ping-pong under rapid copies. Bookkeeping
// (lastX/lastW) is only updated once the push succeeds, so a failed push is
// retried on the next event or backstop poll instead of stalling.

func (s *syncer) onXChange() {
	s.mu.Lock()
	defer s.mu.Unlock()
	st := xState()
	if st == nil {
		// empty or unreadable: keep the Wayland side as-is
		return
	}
	if s.lastX != nil && st.digest == s.lastX.digest {
		return
	}
	if s.lastW != nil && st.digest == s.lastW.digest {
		debugf("X -> W: already in sync, skipping")
		return
	}
	log.Printf("%s: %s", xLabel, st.kind)
	mime := wKindMimes[st.kind]
	if mime == "" {
		log.Printf("X -> W: unknown kind %s", st.kind)
		return
	}
	if !wlCopy(s.pool, mime, st.data) {
		log.Printf("wl-copy %s failed", mime)
		return
	}
	log.Printf("X -> W: synced %s (%d bytes)", st.kind, len(st.data))
	s.lastX = st
	s.lastW = destinationAfterPush(st, wState)
}

func (s *syncer) onWChange() {
	s.mu.Lock()
	defer s.mu.Unlock()
	st := wState()
	if st == nil {
		return
	}
	if s.lastW != nil && st.digest == s.lastW.digest {
		return
	}
	if s.lastX != nil && st.digest == s.lastX.digest {
		debugf("W -> X: already in sync, skipping")
		return
	}
	log.Printf("%s: %s", wLabel, st.kind)
	target := xKindTargets[st.kind]
	if target == "" {
		log.Printf("W -> X: unknown kind %s", st.kind)
		return
	}
	if !xSet(s.pool, target, st.data) {
		log.Printf("xclip %s failed", target)
		return
	}
	log.Printf("W -> X: synced %s (%d bytes)", st.kind, len(st.data))
	s.lastW = st
	s.lastX = destinationAfterPush(st, xState)
}
