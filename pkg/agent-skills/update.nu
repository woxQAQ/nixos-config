#!/usr/bin/env nu
use ../../scripts/lib/pkg-update.nu pins-plan
const package_file = path self default.nix

def main [updates: string] {
    pins-plan $package_file ($updates | from json) | to json
}
