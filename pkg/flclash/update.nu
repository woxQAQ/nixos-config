#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu nix-string
use ../../scripts/lib/pkg-update.nu replace-once
const package_dir = path self .
const package_file = path self default.nix
const updater = path self
const repo_root = path self ../..

# A fake fixed-output hash makes Nix report the actual vendored dependency hash.
def refresh-hash [attribute: string, assignment: string] {
    let source = (open --raw $package_file)
    let matches = ($source | parse --regex $assignment)
    if ($matches | length) != 1 { error make {msg: $"Ambiguous dependency hash for ($attribute)"} }
    let before = $matches.0.assignment
    let fake = ($before | str replace --regex '"sha256-[^"]+"' 'lib.fakeHash')
    replace-once $source $before $fake | save --raw --force $package_file
    let target = $"path:($repo_root)#nixosConfigurations.woxQAQ.pkgs.flclash.($attribute)"
    let built = (^nix build --no-link --no-write-lock-file $target | complete)
    let hashes = ($built.stderr | parse --regex 'got:\s+(?P<hash>sha256-[A-Za-z0-9+/=]+)' | get hash | uniq)
    if $built.exit_code == 0 or ($hashes | length) != 1 {
        error make {msg: $"Could not obtain dependency hash for ($attribute): ($built.stderr)"}
    }
    let fixed = ($fake | str replace 'lib.fakeHash' $'"($hashes.0)"')
    replace-once (open --raw $package_file) $fake $fixed | save --raw --force $package_file
}

def apply-update [row: record] {
    if $nu.os-info.name != 'linux' { error make {msg: 'Updating FlClash requires a Linux builder'} }
    let version = $row.latest
    if $version !~ '^\d+(\.\d+)*$' { error make {msg: 'Invalid FlClash version'} }
    let args = [--url https://github.com/chen08209/FlClash --rev $"v($version)" --fetch-submodules --quiet]
    let fetched = (with-env {
        GIT_CONFIG_COUNT: '1'
        GIT_CONFIG_KEY_0: 'url.https://github.com/.insteadOf'
        GIT_CONFIG_VALUE_0: 'git@github.com:'
    } {
        if (which nix-prefetch-git | is-empty) {
            ^nix run --inputs-from $repo_root nixpkgs#nix-prefetch-git -- ...$args | complete
        } else {
            ^nix-prefetch-git ...$args | complete
        }
    })
    if $fetched.exit_code != 0 { error make {msg: $fetched.stderr} }
    let hash = ($fetched.stdout | from json | get hash)
    let source = (open --raw $package_file)
    let old = ($source | parse --regex '(?s)src = fetchFromGitHub \{.*?hash = "(?P<hash>sha256-[^"]+)";' | get hash | first)
    let revised = (replace-once $source $'version = "($row.current)";' $'version = "($version)";')
    replace-once $revised $old $hash | save --raw --force $package_file

    refresh-hash 'core.goModules' '(?P<assignment>vendorHash = "sha256-[^"]+";)'
    refresh-hash cargoDeps '(?P<assignment>cargoRoot = "plugins/rust_api/rust";\s+hash = "sha256-[^"]+";)'
    refresh-hash helperCargoDeps '(?P<assignment>cargoRoot = "services/helper";\s+hash = "sha256-[^"]+";)'

    http get --raw --max-time 30sec $"https://raw.githubusercontent.com/chen08209/FlClash/v($version)/pubspec.lock"
        | from yaml | to json | save --raw --force ($package_dir | path join pubspec.lock.json)
    let prefix = $"path:($repo_root)#nixosConfigurations.woxQAQ.pkgs"
    let generator = (^nix build --no-link --no-write-lock-file --print-out-paths $"($prefix).dart.fetchGitHashesScript" | complete)
    if $generator.exit_code != 0 { error make {msg: $generator.stderr} }
    let generated = (run-external ...[($generator.stdout | str trim) '--input' ($package_dir | path join pubspec.lock.json) '--output' ($package_dir | path join git-hashes.json)] | complete)
    if $generated.exit_code != 0 { error make {msg: $generated.stderr} }
    let built = (^nix build --no-link --no-write-lock-file $"($prefix).flclash" | complete)
    if $built.exit_code != 0 { error make {msg: $built.stderr} }
}

# Prepare a rollback snapshot; the entry point executes the full native update.
def main [updates: string, --apply] {
    let rows = ($updates | from json)
    if ($rows | length) != 1 or $rows.0.status != 'update' {
        error make {msg: 'FlClash updater requires one numeric version update'}
    }
    if (nix-string $package_file version) != $rows.0.current {
        error make {msg: 'FlClash version changed since the update check'}
    }
    if $apply { apply-update $rows.0; return }
    {
        command: [$nu.current-exe '--no-config-file' $updater $updates '--apply']
        environment: {}
        files: ([default.nix pubspec.lock.json git-hashes.json] | each {|name|
            let file = ($package_dir | path join $name)
            {path: $file, original: (open --raw $file)}
        })
    } | to json
}
