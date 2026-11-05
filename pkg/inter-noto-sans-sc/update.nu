#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu [replace-once prefetch]
const package_file = path self default.nix

# Only the pinned Noto sources change; the merged font has a local version.
def noto-plan [file: path, updates: list] {
    if ($updates | length) != 1 or $updates.0.status != 'update' {
        error make {msg: 'Noto updater requires one numeric version update'}
    }
    let row = $updates.0
    let original = (open --raw $file)
    let hashes = ($original | parse --regex '"(?P<hash>sha256-[A-Za-z0-9+/=]+)"' | get hash)
    if ($hashes | length) != 2 { error make {msg: 'Expected Noto font and license hashes'} }
    let prefix = $"https://raw.githubusercontent.com/notofonts/noto-cjk/Sans($row.latest)"
    let urls = [$"($prefix)/Sans/Variable/TTF/NotoSansCJKsc-VF.ttf" $"($prefix)/LICENSE"]
    let old = $"noto-cjk/Sans($row.current)/"
    if (($original | split row $old | length) - 1) != 2 {
        error make {msg: 'Expected two pinned Noto URLs'}
    }
    mut updated = ($original | str replace --all $old $"noto-cjk/Sans($row.latest)/")
    for asset in ($urls | enumerate) {
        $updated = (replace-once $updated ($hashes | get $asset.index) (prefetch $asset.item))
    }
    {path: $file, original: $original, updated: $updated}
}

def main [updates: string] {
    noto-plan $package_file ($updates | from json) | to json
}
