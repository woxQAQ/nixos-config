$env.config = {
    history: {
        file_format: "sqlite"
        max_size: 5_000_000
        isolation: true
    }
    show_banner: false
    buffer_editor: ["nvim", "--clean"]
    completions: {
        case_sensitive: false
        quick: true
        algorithm: "prefix"
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

# Proxy helper functions
export-env {
    $env.HTTP_PROXY = null
    $env.HTTPS_PROXY = null
    $env.http_proxy = null
    $env.https_proxy = null
    $env.ALL_PROXY = null
    $env.all_proxy = null
    $env.NO_PROXY = null
    $env.no_proxy = null
}

# Set HTTP and HTTPS proxy
export def set-proxy [
    proxy_url: string = "http://127.0.0.1:7890"  # Proxy URL (e.g., http://proxy.example.com:8080)
    --no-proxy: string  # Comma-separated list of hosts that should not use proxy
] {
    let proxy = $proxy_url
    $env.HTTP_PROXY = $proxy
    $env.HTTPS_PROXY = $proxy
    $env.http_proxy = $proxy
    $env.https_proxy = $proxy
    $env.ALL_PROXY = $proxy
    $env.all_proxy = $proxy
    
    if $no_proxy != null {
        $env.NO_PROXY = $no_proxy
        $env.no_proxy = $no_proxy
    }
    
    print $"✅ Proxy set to: ($proxy)"
    if $no_proxy != null {
        print $"✅ No proxy exceptions: ($no_proxy)"
    }
}

# Unset (clear) proxy settings
export def unset-proxy [] {
    $env.HTTP_PROXY = null
    $env.HTTPS_PROXY = null
    $env.http_proxy = null
    $env.https_proxy = null
    $env.ALL_PROXY = null
    $env.all_proxy = null
    $env.NO_PROXY = null
    $env.no_proxy = null
    
    print "✅ Proxy settings cleared"
}

# Show current proxy settings
export def show-proxy [] {
    print "Current proxy settings:"
    print $"HTTP_PROXY: ($env.HTTP_PROXY? | default 'Not set')"
    print $"HTTPS_PROXY: ($env.HTTPS_PROXY? | default 'Not set')"
    print $"http_proxy: ($env.http_proxy? | default 'Not set')"
    print $"https_proxy: ($env.https_proxy? | default 'Not set')"
    print $"ALL_PROXY: ($env.ALL_PROXY? | default 'Not set')"
    print $"all_proxy: ($env.all_proxy? | default 'Not set')"
    print $"NO_PROXY: ($env.NO_PROXY? | default 'Not set')"
    print $"no_proxy: ($env.no_proxy? | default 'Not set')"
}
