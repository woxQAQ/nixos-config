#!/usr/bin/env nu

# DBeaver's version and source hashes are maintained by the nixpkgs input.
def main [] {
    [{source: 'nixpkgs/dbeaver-bin', current: '', latest: '', status: 'skipped', url: '', error: ''}] | to json
}
