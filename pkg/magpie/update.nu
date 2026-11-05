#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu release-plan
const package_file = path self default.nix

def main [updates: string] {
    let rows = ($updates | from json)
    let v = $rows.0.latest
    release-plan $package_file $rows [
        $"https://github.com/yetone/magpie/releases/download/v($v)/magpie-linux-amd64"
        $"https://github.com/yetone/magpie/releases/download/v($v)/magpie-linux-arm64"
        $"https://raw.githubusercontent.com/yetone/magpie/v($v)/build/icon/magpie.svg"
        $"https://raw.githubusercontent.com/yetone/magpie/v($v)/LICENSE"
    ] | to json
}
