#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu github-pins

const package_file = path self default.nix

def main [] {
    github-pins $package_file | to json
}
