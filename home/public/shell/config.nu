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
#
# const NU_PLUGIN_DIRS = [
#     ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
# ]

const NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Proxy helper functions

# Set HTTP and HTTPS proxy
export def set-proxy [
    proxy_url: string = "http://127.0.0.1:7890"  # Proxy URL (e.g., http://proxy.example.com:8080)
    --no-proxy: string  # Comma-separated list of hosts that should not use proxy
] {
    let proxy = $proxy_url
    let env_vars = {
        HTTP_PROXY: $proxy,
        HTTPS_PROXY: $proxy,
        http_proxy: $proxy,
        https_proxy: $proxy,
        ALL_PROXY: $proxy,
        all_proxy: $proxy,
    }

    if $no_proxy != null {
        $env_vars | merge { NO_PROXY: $no_proxy, no_proxy: $no_proxy }
    } | load-env

    print $"✅ Proxy set to: ($proxy)"
    if $no_proxy != null {
        print $"✅ No proxy exceptions: ($no_proxy)"
    }
}

# Unset (clear) proxy settings
export def unset-proxy [] {
    {
        HTTP_PROXY: null,
        HTTPS_PROXY: null,
        http_proxy: null,
        https_proxy: null,
        ALL_PROXY: null,
        all_proxy: null,
        NO_PROXY: null,
        no_proxy: null,
    } | load-env

    print "✅ Proxy settings cleared"
}
