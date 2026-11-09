# pnpm supplies command names and flags. Nushell adds project-local values and
# subcommands that pnpm's completion-server does not return.

def "nu-complete pnpm scripts" [] {
  try {
    open package.json
    | get scripts
    | columns
    | where {|name| not ($name | str starts-with ".") }
  } catch { [] }
}

def "nu-complete pnpm dependencies" [] {
  let manifest = try { open package.json } catch { {} }
  [dependencies devDependencies optionalDependencies peerDependencies]
  | each {|field| try { $manifest | get $field | columns } catch { [] } }
  | flatten
  | uniq
}

def "nu-complete pnpm" [spans: list<string>] {
  let line = ($spans | str join " ")
  let native = try {
    with-env {
      COMP_CWORD: ((($spans | length) - 1) | into string)
      COMP_LINE: $line
      COMP_POINT: ($line | str length | into string)
      SHELL: zsh
    } {
      ^pnpm completion-server -- ...$spans | lines
    }
  } catch { [] }

  let prior = ($spans | skip 1 | drop 1)
  let commands = [
    run run-script remove rm uninstall update up upgrade list ls why outdated
    config c store cache pkg env runtime rt audit dist-tag dist-tags owner
    owners team access completion init version
  ]
  let command = ($prior | where {|word| $word in $commands } | get -o 0 | default "")
  let last = if ($prior | is-empty) { "" } else { $prior | last }
  let path = if $command in [runtime rt access] and $last != $command {
    $"($command) ($last)"
  } else {
    $command
  }
  let extra = match $path {
    "" => (nu-complete pnpm scripts)
    "run" | "run-script" => (nu-complete pnpm scripts)
    "remove" | "rm" | "uninstall" | "update" | "up" | "upgrade" | "list" | "ls" | "why" | "outdated" => (nu-complete pnpm dependencies)
    "config" | "c" => [get set delete list]
    "store" => [add path prune status]
    "cache" => [delete list list-registries view]
    "pkg" => [get set delete fix]
    "env" => [use list ls]
    "runtime" | "rt" => [set]
    "runtime set" | "rt set" => [node deno bun]
    "audit" => [signatures]
    "dist-tag" | "dist-tags" | "owner" | "owners" => [add ls rm]
    "team" => [add create destroy ls rm]
    "access" => [get grant list revoke set]
    "access list" => [packages collaborators]
    "access get" => [status]
    "access set" => [status mfa]
    "completion" => [bash fish pwsh zsh]
    "version" => [major minor patch premajor preminor prepatch prerelease from-git]
    _ => []
  }

  let candidates = ($native | where $it != "__tabtab_complete_files__" | append $extra | uniq)
  if ($candidates | is-empty) { null } else { $candidates }
}

@complete "nu-complete pnpm"
export extern pnpm []
