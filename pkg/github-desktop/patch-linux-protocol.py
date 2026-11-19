"""Teach GitHub Desktop's bundled main.js to accept protocol URLs on Linux.

Upstream registers the OAuth callback scheme through a .desktop entry
(`Exec=github-desktop %u`), so the URL arrives as a plain argv element. The
released 3.6.x main process only ever inspected `--cli-open`/`--cli-clone`,
and `app.on('open-url')` is macOS-only (Electron never emits it on Linux),
so the callback URL was dropped and sign-in could never complete.

desktop/desktop gained the Linux branch after 3.6.12-beta2 (see
`isLinuxProtocolLaunch` in app/src/main-process/main.ts). Until a release
carries it we splice the same logic into the minified bundle: find the
protocol-URL handler that the `open-url` listener calls, expose it, and let
`Rt()` (the command line handler) dispatch to it.

The edit is intentionally a no-op when the fix is already present, so the
override keeps working once nixpkgs ships a fixed upstream.

This file is invoked by default.nix, not by users.
"""

import sys


# Failure modes are reported with a non-zero exit so the Nix build stops
# instead of silently producing a package that still cannot sign in.
def fail(message):
    sys.stderr.write(f"patch-linux-protocol: {message}\n")
    sys.exit(1)


path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    source = f.read()

if "isLinuxProtocolLaunch" in source or "__gdHandleAppURL" in source:
    # Upstream already handles this, or a previous run patched the bundle.
    sys.exit(0)

# The `open-url` listener wraps the real handler as an anonymous function
# expression that is immediately invoked. Locate it by its log message.
HANDLER_HEAD = 'function(e){log.info("Processing protocol url");'
# The same expression closes right after it dispatches to the renderer.
HANDLER_TAIL = "kt(e=>{e.focus(),e.sendURLAction(t)})}"

start = source.find(HANDLER_HEAD)
if start < 0:
    fail("could not locate the protocol URL handler")
end = source.find(HANDLER_TAIL, start)
if end < 0:
    fail("could not locate the end of the protocol URL handler")
end += len(HANDLER_TAIL)
# `handler` is a function expression taking the URL as its single parameter.
handler = source[start:end]
# Keep everything after the opening brace, including the closing one, so the
# spliced body stays a self-contained function body.
body = handler[handler.index("{") + 1 :]

# Replace the anonymous handler with a reference to a global so that both the
# command line handler and the `open-url` listener can reach it. Ordering
# matters: `Rt(process.argv)` runs during module evaluation, before any
# declaration we could prepend, so the reference has to be resolved lazily
# rather than declared textually earlier.
source = source[:start] + "globalThis.__gdHandleAppURL" + source[end:]

OLD_RT = (
    'async function Rt(e){const t=yt()(e,{boolean:["protocol-launcher"]});'
    '"string"==typeof t["cli-open"]?Mt({kind:"open-repository",path:t["cli-open"]}):'
    '"string"==typeof t["cli-clone"]&&Mt({kind:"clone-url",url:t["cli-clone"],'
    'branch:"string"==typeof t["cli-branch"]?t["cli-branch"]:void 0})}'
)
if OLD_RT not in source:
    fail("could not locate Rt(); upstream bundle shape changed")

# The handler is reached from the initial launch, the second-instance event and
# (should Electron ever emit it here) `open-url`. De-duplicating inside the
# handler keeps every entry point idempotent, so the renderer is not asked to
# act on the same callback more than once.
HANDLER_DEF = (
    "globalThis.__gdHandleAppURL=function(e){"
    "if(globalThis.__gdSeen===e)return;"
    "globalThis.__gdSeen=e;" + body
)

NEW_RT = (
    "async function Rt(e){"
    "if(!globalThis.__gdHandleAppURL)" + HANDLER_DEF + ";"
    'const t=yt()(e,{boolean:["protocol-launcher"]}),'
    '__gdP=["x-github-client://","x-github-desktop-dev-auth://","x-github-desktop-auth://"],'
    "__gdU=e.find(a=>__gdP.some(p=>a.startsWith(p)));"
    'if(typeof __gdU==="string"){'
    "try{new URL(__gdU),globalThis.__gdHandleAppURL(__gdU)}catch(_){}"
    "return}"
    '"string"==typeof t["cli-open"]?Mt({kind:"open-repository",path:t["cli-open"]}):'
    '"string"==typeof t["cli-clone"]&&Mt({kind:"clone-url",url:t["cli-clone"],'
    'branch:"string"==typeof t["cli-branch"]?t["cli-branch"]:void 0})}'
)

source = source.replace(OLD_RT, NEW_RT, 1)

with open(path, "w", encoding="utf-8") as f:
    f.write(source)
