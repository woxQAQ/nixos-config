#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu release-plan
const package_file = path self default.nix

def main [updates: string] {
    let rows = ($updates | from json)
    let v = $rows.0.latest
    release-plan $package_file $rows [
        $"https://github.com/lxgw/yozai-font/releases/download/v($v)/Yozai-Light.ttf"
        $"https://github.com/lxgw/yozai-font/releases/download/v($v)/Yozai-Medium.ttf"
        $"https://github.com/lxgw/yozai-font/releases/download/v($v)/Yozai-Regular.ttf"
        $"https://raw.githubusercontent.com/lxgw/yozai-font/v($v)/OFL.txt"
    ] | to json
}
