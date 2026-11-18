#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu nix-string
use ../../scripts/lib/pkg-update.nu [replace-once prefetch]

const package_dir = path self .
const package_file = path self default.nix
const linux_file = path self linux.nix
const updater = path self
const repo_root = path self ../..

def refresh-hash [attribute: string, assignment: string] {
    let original = (open --raw $linux_file)
    let matches = ($original | parse --regex $assignment)
    if ($matches | length) != 1 { error make {msg: $"Ambiguous dependency hash for ($attribute)"} }
    let before = $matches.0.assignment
    let fake = ($before | str replace --regex '"sha256-[^"]+"' 'lib.fakeHash')
    replace-once $original $before $fake | save --raw --force $linux_file
    let target = $"path:($repo_root)#nixosConfigurations.woxQAQ.pkgs.neuve.($attribute)"
    let built = (^nix build --no-link --no-write-lock-file $target | complete)
    let hashes = ($built.stderr | parse --regex 'got:\s+(?P<hash>sha256-[A-Za-z0-9+/=]+)' | get hash | uniq)
    if $built.exit_code == 0 or ($hashes | length) != 1 {
        error make {msg: $"Could not obtain dependency hash for ($attribute): ($built.stderr)"}
    }
    let fixed = ($fake | str replace 'lib.fakeHash' $'"($hashes.0)"')
    replace-once (open --raw $linux_file) $fake $fixed | save --raw --force $linux_file
}

def apply-update [row: record] {
    if $nu.os-info.name != 'linux' { error make {msg: 'Updating Neuve requires a Linux builder'} }
    let v = $row.latest
    if $v !~ '^\d+\.\d+\.\d+([+-][A-Za-z0-9.-]+)?$' { error make {msg: 'Invalid Neuve version'} }
    let asset = $"https://github.com/NeuveAI/neuve/releases/download/v($v)/neuve-darwin-arm64.tar.gz"
    let fetched = (^nix store prefetch-file --json $asset | complete)
    if $fetched.exit_code != 0 { error make {msg: $fetched.stderr} }
    let release = ($fetched.stdout | from json)
    let metadata = (^tar -xOzf $release.storePath neuve-darwin-arm64/lib/neuve/release.json | from json)
    let revision = $metadata.graphRevision
    if $metadata.version != $v or $revision !~ '^[0-9a-f]{40}$' {
        error make {msg: 'Release metadata has no matching version and Graph revision'}
    }
    let original = (open --raw $package_file)
    let old_hash = ($original | parse --regex 'hash = "(?P<hash>sha256-[^"]+)";' | get hash | first)
    $original | str replace $'version = "($row.current)";' $'version = "($v)";'
        | str replace $old_hash $release.hash | save --raw --force $package_file

    let linux = (open --raw $linux_file)
    let hashes = ($linux | parse --regex 'hash = "(?P<hash>sha256-[^"]+)";' | get hash)
    let old_revision = (nix-string $linux_file graphRevision)
    let source_hash = (prefetch $"https://github.com/NeuveAI/neuve/archive/refs/tags/v($v).tar.gz" --unpack)
    let graph_hash = (prefetch $"https://github.com/NeuveAI/neuve-graph/archive/($revision).tar.gz" --unpack)
    $linux | str replace $hashes.0 $source_hash | str replace $hashes.1 $graph_hash
        | str replace $old_revision $revision | save --raw --force $linux_file
    refresh-hash 'graph.goModules' '(?P<assignment>vendorHash = "sha256-[^"]+";)'
    refresh-hash nodeModules '(?P<assignment>outputHash = "sha256-[^"]+";)'
    let built = (^nix build --no-link --no-write-lock-file $"path:($repo_root)#packages.x86_64-linux.neuve" | complete)
    if $built.exit_code != 0 { error make {msg: $built.stderr} }
}

def main [updates: string, --apply] {
    let rows = ($updates | from json)
    if ($rows | length) != 1 or $rows.0.status != 'update' {
        error make {msg: 'Neuve updater requires one version update'}
    }
    if (nix-string $package_file version) != $rows.0.current {
        error make {msg: 'Neuve version changed since the update check'}
    }
    if $apply { apply-update $rows.0; return }
    {
        command: [$nu.current-exe '--no-config-file' $updater $updates '--apply']
        environment: {}
        files: ([default.nix linux.nix] | each {|name|
            let file = ($package_dir | path join $name)
            {path: $file, original: (open --raw $file)}
        })
    } | to json
}
