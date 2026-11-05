#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu [github nix-string result]

const package_file = path self default.nix

def main [] {
    let current = (nix-string $package_file version)
    [ (result 'Warren2060/ChillRound (ChillRoundF)' $current {
        mut candidates = []
        mut page = 1
        loop {
            let releases = (github $"repos/Warren2060/ChillRound/releases?per_page=100&page=($page)")
            let full_round = ($releases | where {|release| not $release.draft and not $release.prerelease } | each {|release|
                $release.assets | get name | parse --regex '^ChillRoundF_v(?P<version>[0-9.]+)\.zip$' | each {|asset|
                    {version: $asset.version, url: $release.html_url}
                }
            } | flatten)
            $candidates = ($candidates | append $full_round)
            if ($releases | length) < 100 { break }
            $page = $page + 1
        }
        # Full-round and half-round fonts have independent version sequences.
        $candidates | sort-by --natural version | last
    }) ] | to json
}
