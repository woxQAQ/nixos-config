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

def loc [path: path = .] {
   tokei -o json $path | from json
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
