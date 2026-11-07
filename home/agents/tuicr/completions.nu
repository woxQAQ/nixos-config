# Keep the left revision intact while completing the right side of a range.
def "nu-complete tuicr revisions" [buffer: string, place: record] {
  let token = ($buffer | str substring ..<$place.cursor | split row --regex '\s+' | last)
  let range = ($token | parse --regex '^(?<base>.*?\.{2,3})[^.]*$')
  let base = ($range | get -o 0.base | default '')
  let refs = (do { ^git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags } | complete)
  if $refs.exit_code != 0 { return [] }

  $refs.stdout
  | lines
  | prepend HEAD
  | uniq
  | each {|ref| $base + $ref }
}

def "nu-complete tuicr appearance" [] { [light dark system] }

def "nu-complete tuicr remotes" [] {
  let result = (do { ^git remote } | complete)
  if $result.exit_code == 0 { $result.stdout | lines } else { [] }
}

# Review changes in the current checkout.
export extern tuicr [
  --revisions(-r): string@"nu-complete tuicr revisions" # Commit or revision range
  --theme: string                 # Bundled or local color theme
  --appearance: string@"nu-complete tuicr appearance" # Color mode
  --path(-p): path                # Filter the diff to a file or directory
  --working-tree(-w)              # Include uncommitted changes
  --file: path                    # Open a file or directory for annotation
  --all-files(-A)                 # Review every tracked file
  --stdout                       # Export to stdout
  --no-update-check               # Skip startup update checks
  --repo-url: string              # Override the forge repository
  --remote: string@"nu-complete tuicr remotes" # Use a named Git remote
  --help(-h)                      # Print help
  --version(-V)                   # Print version
]

# Open the interactive review TUI.
export extern "tuicr tui" [
  --revisions(-r): string@"nu-complete tuicr revisions" # Commit or revision range
  --theme: string
  --appearance: string@"nu-complete tuicr appearance"
  --path(-p): path
  --working-tree(-w)
  --file: path
  --all-files(-A)
  --stdout
  --no-update-check
  --repo-url: string
  --remote: string@"nu-complete tuicr remotes"
  --help(-h)
]

# Review a GitHub pull request or GitLab merge request.
export extern "tuicr pr" [target: string, --help(-h)]
export extern "tuicr mr" [target: string, --help(-h)]
export extern "tuicr tui pr" [target: string, --help(-h)]
export extern "tuicr tui mr" [target: string, --help(-h)]

# Inspect or update persisted review sessions.
export extern "tuicr review" [--help(-h)]
export extern "tuicr review list" [...args: string, --help(-h)]
export extern "tuicr review add" [...args: string, --help(-h)]
export extern "tuicr review comments" [...args: string, --help(-h)]
export extern "tuicr review delete" [...args: string, --help(-h)]
export extern "tuicr review clearc" [...args: string, --help(-h)]
export extern "tuicr review clear" [...args: string, --help(-h)]

# Install a specific release or update to the latest version.
export extern "tuicr update" [version?: string, --help(-h)]
