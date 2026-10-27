$env.config = {
    history: {
        file_format: "sqlite"
        max_size: 5_000_000
        isolation: true
    }
    show_banner: false
    recursion_limit: 50
    edit_mode: "vi"
    buffer_editor: ["nvim", "--clean"]
    cursor_shape: {
        vi_insert: "block"
        vi_normal: "underscore"
    }
    completions: {
        case_sensitive: false
        quick: true
        algorithm: "fuzzy"
        partial: true
    }
    use_kitty_protocol: false
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }
}

const NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Count source lines, excluding submodule paths declared in .gitmodules.
def loc [
    path: path = .
    --include-submodules # Include submodule code in the totals.
] {
    let target = ($path | path expand)
    let directory = if ($target | path type) == dir { $target } else { $target | path dirname }
    let repo = (^git -C $directory rev-parse --show-toplevel | complete)
    let root = if $repo.exit_code == 0 { $repo.stdout | str trim | path expand } else { $directory }
    let gitmodules = ($root | path join .gitmodules)
    let submodules = if not $include_submodules and ($gitmodules | path exists) {
        let paths = (^git config get --file $gitmodules --null --all --regexp '^submodule\..*\.path$' | complete)
        if $paths.exit_code not-in [0 1] {
            error make {msg: $paths.stderr}
        }
        $paths.stdout | split row (char nul) | where $it != ''
            | each { |submodule| $root | path join $submodule | path expand }
    } else { [] }
    if ($submodules | any { |submodule|
        $target == $submodule or ($target | str starts-with $'($submodule)/')
    }) {
        return []
    }
    let excludes = ($submodules | each { |submodule|
        let relative = ($submodule | path relative-to $root)
        let pattern = ($relative | str replace --all --regex '([\\*?\[\]{}])' '\$1')
        [--exclude $'/($pattern)']
    } | flatten)
    # Tokei matches anchored exclusions against relative inputs from its working directory.
    cd $root
    let relative = ($target | path relative-to $root)
    let input = if ($relative | is-empty) { '.' } else { $relative }
    tokei -o json ...$excludes -- $input | from json
        | transpose lang stats
        | each { |it|
            $it.stats
            | reject reports children inaccurate
            | insert files ($it.stats.reports | length)
            | insert lang $it.lang
        }
        | select lang files code comments blanks
        | where lang != Total
        | sort-by code -r
}
