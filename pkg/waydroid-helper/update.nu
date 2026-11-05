#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu release-plan
const package_file = path self default.nix

def main [updates: string] {
    let rows = ($updates | from json)
    let v = $rows.0.latest
    release-plan $package_file $rows [
        $"https://github.com/waydroid-helper/waydroid-helper/archive/refs/tags/v($v).tar.gz"
    ] --unpack | to json
}
