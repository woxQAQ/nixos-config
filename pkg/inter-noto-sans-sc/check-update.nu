#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu github-tags

const package_file = path self default.nix

def main [] {
    let source = (open --raw $package_file)
    let pins = ($source | parse --regex 'noto-cjk/Sans(?P<version>[0-9.]+)/Sans/')
    if ($pins | length) != 1 {
        error make {msg: 'Expected one pinned Noto Sans source'}
    }
    [ (github-tags 'notofonts/noto-cjk' 'Sans' $pins.0.version) ] | to json
}
