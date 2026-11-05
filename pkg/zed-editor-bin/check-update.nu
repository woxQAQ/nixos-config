#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu github-release

const package_file = path self default.nix

def main [] {
    [ (github-release $package_file 'zed-industries/zed') ] | to json
}
