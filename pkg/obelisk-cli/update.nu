#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu [prefetch replace-once]
const package_file = path self default.nix

# Bump the CLI version and refresh the npm tarball hash.
def release-edit [text: string, row: record] {
    if $row.status != 'update' {
        error make {msg: 'CLI updater requires a numeric version update'}
    }
    let matches = $text | parse --regex '(?s)(?P<block>fetchurl\s*\{\s*url\s*=\s*"[^"]+";\s*hash\s*=\s*"(?P<hash>sha256-[^"]+)";\s*\})'
    if ($matches | length) != 1 { error make {msg: 'Expected exactly one fetchurl source'} }
    let block = $matches.0.block
    let old_hash = $matches.0.hash
    let hash = prefetch $"https://registry.npmjs.org/@obelisk-apps/cli/-/cli-($row.latest).tgz"
    let revised = $block | str replace $old_hash $hash
    let versioned = replace-once $text $'version = "($row.current)";' $'version = "($row.latest)";'
    replace-once $versioned $block $revised
}

# Repin the companion skill repository.
def pin-edit [text: string, row: record] {
    if $row.status != 'changed' or $row.latest !~ '^[0-9a-f]{40}$' {
        error make {msg: 'Skill updater requires a full commit SHA'}
    }
    let blocks = $text | parse --regex '(?s)(?P<block>fetchFromGitHub\s*\{[^}]+\})' | get block
    if ($blocks | length) != 1 { error make {msg: 'Expected exactly one fetchFromGitHub source'} }
    let block = $blocks.0
    let old_hash = $block | parse --regex 'hash = "(?P<hash>sha256-[^"]+)";' | get hash | first
    let hash = prefetch $"https://github.com/($row.source)/archive/($row.latest).tar.gz" --unpack
    let revised = (
        $block
        | str replace $'rev = "($row.current)";' $'rev = "($row.latest)";'
        | str replace $old_hash $hash
    )
    replace-once $text $block $revised
}

def main [updates: string] {
    let rows = $updates | from json
    let original = open --raw $package_file
    mut updated = $original
    for row in $rows {
        $updated = if $row.source == '@obelisk-apps/cli' {
            release-edit $updated $row
        } else {
            pin-edit $updated $row
        }
    }
    {path: $package_file, original: $original, updated: $updated} | to json
}
