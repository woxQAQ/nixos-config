#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu release-plan
const package_file = path self default.nix

def main [updates: string] {
    let rows = ($updates | from json)
    let v = $rows.0.latest
    release-plan $package_file $rows [
        $"https://github.com/CyanoHao/Resource-Han-Rounded/releases/download/v($v)/RHR-CN-($v).7z"
        $"https://raw.githubusercontent.com/CyanoHao/Resource-Han-Rounded/v($v)/LICENSE.txt"
    ] | to json
}
