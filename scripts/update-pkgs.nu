#!/usr/bin/env nu

const repo_root = path self ..
const check_script = path self check-pkg-updates.nu

# Validate prepared Nix text before replacing the original file.
def validate-nix [text: string] {
    let temporary = (^mktemp -d | str trim)
    try {
        let candidate = ($temporary | path join default.nix)
        $text | save --raw $candidate
        let parsed = (^nix-instantiate --parse $candidate | complete)
        if $parsed.exit_code != 0 { error make {msg: $parsed.stderr} }
    } catch {|err|
        rm --recursive $temporary
        error make {msg: $err.msg}
    }
    rm --recursive $temporary
}

def apply-plan [plan: record, directory: path] {
    if 'command' in $plan {
        for file in $plan.files {
            if (open --raw $file.path) != $file.original {
                error make {msg: $"File changed while preparing update: ($file.path)"}
            }
        }
        try {
            let execution = (with-env $plan.environment { run-external ...$plan.command } | complete)
            if $execution.exit_code != 0 {
                error make {msg: ($execution.stdout + $execution.stderr)}
            }
            if $execution.stdout != '' { print $execution.stdout }
        } catch {|err|
            for file in $plan.files { $file.original | save --raw --force $file.path }
            error make {msg: $err.msg}
        }
    } else {
        let expected = ($directory | path join default.nix)
        if $plan.path != $expected { error make {msg: 'Updater returned an unexpected target path'} }
        validate-nix $plan.updated
        if (open --raw $plan.path) != $plan.original {
            error make {msg: $"File changed while preparing update: ($plan.path)"}
        }
        $plan.updated | save --raw --force $plan.path
    }
}

# Check upstream versions, choose sources interactively, then update their pins.
def main [
    ...packages: string # Limit the check to these package directories.
    --jobs: int = 4 # Concurrent package checks; updates run sequentially.
    --all # Select every available update without opening the interactive list.
    --dry-run # Display the selection without downloading or editing packages.
] {
    let nu_executable = $nu.current-exe
    print --stderr 'Checking upstream versions…'
    let checked = (^$nu_executable --no-config-file $check_script ...$packages --json --jobs $jobs | complete)
    if $checked.stdout == '' {
        error make {msg: $checked.stderr}
    }
    let rows = ($checked.stdout | from json)
    let errors = ($rows | where status == error)
    if not ($errors | is-empty) {
        print --stderr ($errors | select package source error | table --expand)
    }
    let candidates = ($rows | where {|row| $row.status in [update changed] })
    if ($candidates | is-empty) {
        print 'No available updates.'
        if not ($errors | is-empty) { exit 1 }
        return
    }
    let selected = if $all {
        $candidates
    } else {
        $candidates | input list --multi --fuzzy --display {|row|
            let current = if ($row.current | str length) == 40 { $row.current | str substring 0..11 } else { $row.current }
            let latest = if ($row.latest | str length) == 40 { $row.latest | str substring 0..11 } else { $row.latest }
            $"($row.package) / ($row.source): ($current) → ($latest)"
        } 'Select updates (Tab to toggle, Enter to apply, Esc to cancel)'
    }
    if ($selected | is-empty) { print 'No updates selected.'; return }
    print ($selected | select package source current latest | table --expand)
    if $dry_run {
        if not ($errors | is-empty) { exit 1 }
        return
    }
    mut failures = []
    for group in ($selected | group-by package | transpose package updates) {
        let directory = ($repo_root | path join pkg $group.package)
        let updater = ($directory | path join update.nu)
        print --stderr $"Updating ($group.package)…"
        let outcome = try {
            if not ($updater | path exists) { error make {msg: 'Missing update.nu'} }
            let prepared = (^$nu_executable --no-config-file $updater ($group.updates | to json --raw) | complete)
            if $prepared.exit_code != 0 { error make {msg: ($prepared.stderr | str trim)} }
            let plan = ($prepared.stdout | from json)
            apply-plan $plan $directory
            print $"Updated ($group.package)."
            {ok: true, error: ''}
        } catch {|err|
            {ok: false, error: $err.msg}
        }
        if not $outcome.ok {
            $failures = ($failures | append {package: $group.package, error: $outcome.error})
            print --stderr $"Failed to update ($group.package): ($outcome.error)"
        }
    }
    if not ($failures | is-empty) or not ($errors | is-empty) { exit 1 }
}
