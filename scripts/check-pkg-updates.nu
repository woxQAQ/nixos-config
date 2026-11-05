#!/usr/bin/env nu

const package_root = path self ../pkg

# Check all packages, or pass package directory names to limit the selection.
def main [
    ...packages: string
    --json # Emit the complete result as JSON.
    --jobs: int = 4 # Maximum number of package checks running concurrently.
] {
    if $jobs < 1 {
        error make {msg: '--jobs must be at least 1'}
    }
    let root = $package_root
    let available = (glob ($root | path join '*/default.nix') | each { path dirname | path basename } | sort)
    let unknown = ($packages | where {|name| $name not-in $available })
    if not ($unknown | is-empty) {
        error make {msg: $"Unknown packages: ($unknown | str join ', ')"}
    }
    let selected = if ($packages | is-empty) { $available } else { $packages | uniq | sort }
    let nu_executable = $nu.current-exe
    let rows = ($selected | par-each --threads $jobs {|package|
        let checker = ($root | path join $package 'check-update.nu')
        if not ($checker | path exists) {
            return [{package: $package, source: '', current: '', latest: '', status: 'error', url: '', error: 'Missing check-update.nu'}]
        }
        try {
            let output = (^$nu_executable --no-config-file $checker | complete)
            if $output.exit_code != 0 {
                error make {msg: ($output.stderr | str trim)}
            }
            let results = ($output.stdout | from json)
            if ($results | describe) !~ '^list|^table' or ($results | is-empty) {
                error make {msg: 'Checker must return a nonempty JSON array'}
            }
            $results | each {|row|
                for column in [source current latest status url error] {
                    if ($row | get $column | describe) != 'string' {
                        error make {msg: $"Invalid checker field: ($column)"}
                    }
                }
                if $row.status not-in [current update ahead changed error] {
                    error make {msg: $"Unknown checker status: ($row.status)"}
                }
                $row | insert package $package | select package source current latest status url error
            }
        } catch {|err|
            [{package: $package, source: '', current: '', latest: '', status: 'error', url: '', error: $err.msg}]
        }
    } | flatten | sort-by package source)
    if $json {
        print ($rows | to json)
    } else {
        print ($rows | table --expand)
    }
    if ($rows | any {|row| $row.status == 'error' }) {
        exit 1
    }
}
