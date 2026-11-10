#!/usr/bin/env nu

# The local merge has no upstream pin; its inputs are updated independently.
def main [] {
    [{source: 'nixpkgs/ioskeley-mono + chillroundf', current: '', latest: '', status: 'skipped', url: '', error: ''}] | to json
}
