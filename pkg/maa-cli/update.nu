#!/usr/bin/env nu
# maa-cli >= 0.7.3 eagerly binds AsstAsyncAttachWindow (maa-sys 0.10), which
# only exists on MAA's unreleased dev branch; upgrading before a stable MaaCore
# exports it breaks core loading. See the note in default.nix.
def main [updates: string] {
    error make {
        msg: 'maa-cli is pinned below 0.7.3 until a stable MaaCore exports AsstAsyncAttachWindow'
    }
}
