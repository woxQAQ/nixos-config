# Package updaters prepare complete file contents; the entry point commits them.

export def replace-once [text: string, old: string, new: string] {
    if (($text | split row $old | length) - 1) != 1 {
        error make {msg: $"Expected exactly one occurrence of: ($old)"}
    }
    $text | str replace $old $new
}

export def prefetch [url: string, --unpack] {
    let flags = if $unpack { ['--unpack'] } else { [] }
    let fetched = (^nix store prefetch-file --json --hash-type sha256 ...$flags $url | complete)
    if $fetched.exit_code != 0 {
        error make {msg: $"Prefetch failed for ($url): ($fetched.stderr | str trim)"}
    }
    $fetched.stdout | from json | get hash
}

export def release-plan [file: path, updates: list, urls: list<string>, --unpack] {
    if ($updates | length) != 1 or $updates.0.status != 'update' {
        error make {msg: 'Release updater requires one numeric version update'}
    }
    let row = $updates.0
    let original = (open --raw $file)
    let hashes = ($original | parse --regex '"(?P<hash>sha256-[A-Za-z0-9+/=]+)"' | get hash)
    if ($hashes | length) != ($urls | length) {
        error make {msg: $"Source layout changed: ($hashes | length) hashes but ($urls | length) URLs"}
    }
    mut updated = (replace-once $original $'version = "($row.current)";' $'version = "($row.latest)";')
    for asset in ($urls | enumerate) {
        let hash = if $unpack { prefetch $asset.item --unpack } else { prefetch $asset.item }
        $updated = (replace-once $updated ($hashes | get $asset.index) $hash)
    }
    {path: $file, original: $original, updated: $updated}
}

export def pins-plan [file: path, updates: list] {
    let original = (open --raw $file)
    let blocks = ($original | parse --regex '(?s)(?P<block>fetchFromGitHub\s*\{[^}]+\})' | get block)
    mut updated = $original
    for row in $updates {
        if $row.status != 'changed' or $row.latest !~ '^[0-9a-f]{40}$' {
            error make {msg: 'Commit updater requires a full commit SHA'}
        }
        let matching = ($blocks | where {|block|
            let owner = ($block | parse --regex 'owner = "(?P<value>[^"]+)";' | get value | first)
            let repo = ($block | parse --regex 'repo = "(?P<value>[^"]+)";' | get value | first)
            $"($owner)/($repo)" == $row.source
        })
        if ($matching | length) != 1 { error make {msg: $"Ambiguous source: ($row.source)"} }
        let block = $matching.0
        let old_hash = ($block | parse --regex 'hash = "(?P<hash>sha256-[^"]+)";' | get hash | first)
        let hash = (prefetch $"https://github.com/($row.source)/archive/($row.latest).tar.gz" --unpack)
        let revised = (replace-once $block $'rev = "($row.current)";' $'rev = "($row.latest)";' | str replace $old_hash $hash)
        $updated = (replace-once $updated $block $revised)
    }
    {path: $file, original: $original, updated: $updated}
}
