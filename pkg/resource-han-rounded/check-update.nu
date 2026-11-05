#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu github-release

const package_file = path self default.nix

def main [] {
    [ (github-release $package_file 'CyanoHao/Resource-Han-Rounded') ] | to json
}
