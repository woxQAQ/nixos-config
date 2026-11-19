#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu [replace-once prefetch]
use ../../scripts/lib/pkg-updates.nu [github]
const package_file = path self default.nix

# Besides the version bump, the src/MaaUtils submodule pin must follow the one
# recorded in the new upstream tag.
def main [updates: string] {
    let rows = ($updates | from json)
    if ($rows | length) != 1 or $rows.0.status != 'update' {
        error make {msg: 'Release updater requires one numeric version update'}
    }
    let v = $rows.0.latest
    let original = (open --raw $package_file)
    mut updated = (replace-once $original $'version = "($rows.0.current)";' $'version = "($v)";')

    # Hash literals appear in declaration order: maaUtils first, MAA src second.
    let hashes = ($updated | parse --regex 'hash = "(?P<hash>sha256-[^"]+)";' | get hash)
    if ($hashes | length) != 2 {
        error make {msg: $"Source layout changed: expected 2 hashes, found ($hashes | length)"}
    }

    let src_hash = (prefetch $"https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v($v).tar.gz" --unpack)
    $updated = (replace-once $updated ($hashes | get 1) $src_hash)

    let submodule = (github $"repos/MaaAssistantArknights/MaaAssistantArknights/contents/src/MaaUtils?ref=v($v)")
    let rev = $submodule.sha
    let utils_hash = (prefetch $"https://github.com/MaaXYZ/MaaUtils/archive/($rev).tar.gz" --unpack)
    let old_rev = ($updated | parse --regex 'rev = "(?P<value>[0-9a-f]{40})";' | get value | first)
    $updated = (replace-once $updated $old_rev $rev)
    $updated = (replace-once $updated ($hashes | get 0) $utils_hash)

    {path: $package_file, original: $original, updated: $updated} | to json
}
