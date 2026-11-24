#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu [github-pins npm-release]

const package_file = path self default.nix

def main [] {
    [
        (npm-release $package_file '@obelisk-apps/cli')
        ...(github-pins $package_file)
    ] | to json
}
