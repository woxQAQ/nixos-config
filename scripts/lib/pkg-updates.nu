# Shared protocol: each package checker prints a JSON array of result records.

export def nix-string [file: path, attribute: string] {
    let pattern = ('(?m)^\s*' + $attribute + ' = "(?P<value>[^"\n]+)";\s*$')
    let matches = (open --raw $file | parse --regex $pattern)
    if ($matches | length) != 1 {
        error make {msg: $"Expected one literal ($attribute) in ($file)"}
    }
    $matches.0.value
}

export def github [endpoint: string] {
    let base = ($env.GITHUB_API_URL? | default 'https://api.github.com' | str trim --right --char '/')
    mut headers = {Accept: 'application/vnd.github+json', User-Agent: 'nixos-config-update-check'}
    mut token = ($env.GITHUB_TOKEN? | default ($env.GH_TOKEN? | default ''))
    if $token == '' and not (which gh | is-empty) {
        let auth = (^gh auth token | complete)
        if $auth.exit_code == 0 { $token = ($auth.stdout | str trim) }
    }
    if $token != '' {
        $headers = ($headers | insert Authorization $"Bearer ($token)")
    }
    let response = (http get --max-time 20sec --headers $headers --full --allow-errors $"($base)/($endpoint)")
    if $response.status != 200 {
        let message = ($response.body.message? | default 'GitHub request failed')
        error make {msg: $"HTTP ($response.status): ($message) [($endpoint)]"}
    }
    $response.body
}

export def result [source: string, current: string, query: closure] {
    try {
        let remote = (do $query)
        let latest = $remote.version
        if ($latest | is-empty) {
            error make {msg: 'Upstream returned an empty version'}
        }
        let numeric = '^\d+(\.\d+)*$'
        let status = if $current == $latest {
            'current'
        } else if ($current =~ $numeric) and ($latest =~ $numeric) {
            let a = ($current | split row '.' | each { into int })
            let b = ($latest | split row '.' | each { into int })
            let width = ([$a $b] | each { length } | math max)
            let differences = (0..<$width | each {|i|
                ($b | get --optional $i | default 0) - ($a | get --optional $i | default 0)
            } | where {|n| $n != 0 })
            if ($differences | is-empty) { 'current' } else if $differences.0 > 0 { 'update' } else { 'ahead' }
        } else {
            'changed'
        }
        {source: $source, current: $current, latest: $latest, status: $status, url: $remote.url, error: ''}
    } catch {|err|
        {source: $source, current: $current, latest: '', status: 'error', url: '', error: $err.msg}
    }
}

export def github-release [file: path, repo: string] {
    let current = (nix-string $file version)
    result $repo $current {
        let release = (github $"repos/($repo)/releases/latest")
        {version: ($release.tag_name | str replace --regex '^v' ''), url: $release.html_url}
    }
}

export def github-commit [repo: string, current: string] {
    result $repo $current {
        let commit = (github $"repos/($repo)/commits/HEAD")
        {version: $commit.sha, url: $"https://github.com/($repo)/compare/($current)...($commit.sha)"}
    }
}

# Match literal fetchFromGitHub blocks, including categorized skill collections.
export def github-pins [file: path] {
    let blocks = (open --raw $file | parse --regex '(?s)fetchFromGitHub\s*\{(?P<body>[^}]+)\}')
    if ($blocks | is-empty) {
        error make {msg: $"No literal fetchFromGitHub sources in ($file)"}
    }
    $blocks | each {|block|
        let owner = ($block.body | parse --regex 'owner = "(?P<value>[^"]+)";' | get value | first)
        let repo = ($block.body | parse --regex 'repo = "(?P<value>[^"]+)";' | get value | first)
        let rev = ($block.body | parse --regex 'rev = "(?P<value>[^"]+)";' | get value | first)
        github-commit $"($owner)/($repo)" $rev
    }
}

# Noto publishes independent Sans and Serif tag series in the same repository.
export def github-tags [repo: string, prefix: string, current: string] {
    result $repo $current {
        mut versions = []
        mut page = 1
        loop {
            let tags = (github $"repos/($repo)/tags?per_page=100&page=($page)")
            $versions = ($versions | append ($tags | get name | where {|tag| $tag | str starts-with $prefix }))
            if ($tags | length) < 100 { break }
            $page = $page + 1
        }
        let tag = ($versions | sort --natural | last)
        {version: ($tag | str substring ($prefix | str length)..), url: $"https://github.com/($repo)/releases/tag/($tag)"}
    }
}

export def npm-release [file: path, package: string] {
    let current = (nix-string $file version)
    result $package $current {
        let registry = ($env.NPM_CONFIG_REGISTRY? | default 'https://registry.npmjs.org' | str trim --right --char '/')
        let encoded = ($package | url encode --all)
        let release = (http get --max-time 20sec $"($registry)/($encoded)/latest")
        {version: $release.version, url: $"https://www.npmjs.com/package/($package)/v/($release.version)"}
    }
}
