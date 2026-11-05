#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu release-plan
const package_file = path self default.nix

def main [updates: string] {
    let rows = ($updates | from json)
    let v = $rows.0.latest
    release-plan $package_file $rows [
        $"https://github.com/xishang0128/sparkle/releases/download/($v)/sparkle-linux-($v)-amd64.deb"
        $"https://github.com/xishang0128/sparkle/releases/download/($v)/sparkle-linux-($v)-arm64.deb"
    ] | to json
}
