# Custom completions for the Go command.
# Reference: https://go.dev/cmd/go/

def "nu-complete go commands" [] {
  [
    { value: "bug", description: "Start a bug report" }
    { value: "build", description: "Compile packages and dependencies" }
    { value: "clean", description: "Remove object files and cached files" }
    { value: "doc", description: "Show documentation for a package or symbol" }
    { value: "env", description: "Print Go environment information" }
    { value: "fix", description: "Apply fixes suggested by static checkers" }
    { value: "fmt", description: "Reformat package sources with gofmt" }
    { value: "generate", description: "Generate Go files by processing source" }
    { value: "get", description: "Add dependencies to the current module" }
    { value: "help", description: "Show help for a command or topic" }
    { value: "install", description: "Compile and install packages and dependencies" }
    { value: "list", description: "List packages or modules" }
    { value: "mod", description: "Module maintenance" }
    { value: "run", description: "Compile and run a Go program" }
    { value: "telemetry", description: "Manage telemetry data and settings" }
    { value: "test", description: "Test packages" }
    { value: "tool", description: "Run a specified Go tool" }
    { value: "version", description: "Print the Go version or binary build information" }
    { value: "vet", description: "Report likely mistakes in packages" }
    { value: "work", description: "Workspace maintenance" }
  ]
}

def "nu-complete go mod commands" [] {
  [
    { value: "download", description: "Download modules to the local cache" }
    { value: "edit", description: "Edit go.mod from tools or scripts" }
    { value: "graph", description: "Print the module requirement graph" }
    { value: "init", description: "Initialize a new module in the current directory" }
    { value: "tidy", description: "Add missing and remove unused modules" }
    { value: "vendor", description: "Make a vendored copy of dependencies" }
    { value: "verify", description: "Verify dependencies have expected content" }
    { value: "why", description: "Explain why packages or modules are needed" }
  ]
}

def "nu-complete go work commands" [] {
  [
    { value: "edit", description: "Edit go.work from tools or scripts" }
    { value: "init", description: "Initialize a workspace file" }
    { value: "sync", description: "Sync the workspace build list to its modules" }
    { value: "use", description: "Add modules to a workspace file" }
    { value: "vendor", description: "Make a vendored copy of workspace dependencies" }
  ]
}

def "nu-complete go help topics" [] {
  (nu-complete go commands) | append [
    { value: "buildconstraint", description: "Build constraints" }
    { value: "buildjson", description: "Build -json encoding" }
    { value: "buildmode", description: "Build modes" }
    { value: "c", description: "Calling between Go and C" }
    { value: "cache", description: "Build and test caching" }
    { value: "environment", description: "Environment variables" }
    { value: "filetype", description: "File types" }
    { value: "goauth", description: "GOAUTH environment variable" }
    { value: "go.mod", description: "The go.mod file" }
    { value: "gopath", description: "GOPATH environment variable" }
    { value: "goproxy", description: "Module proxy protocol" }
    { value: "importpath", description: "Import path syntax" }
    { value: "modules", description: "Modules and module versions" }
    { value: "module-auth", description: "Module authentication using go.sum" }
    { value: "packages", description: "Package lists and patterns" }
    { value: "private", description: "Configuration for downloading non-public code" }
    { value: "testflag", description: "Testing flags" }
    { value: "testfunc", description: "Testing functions" }
    { value: "vcs", description: "Version control with GOVCS" }
  ]
}

def "nu-complete go build modes" [] {
  [archive c-archive c-shared default exe pie plugin shared]
}

def "nu-complete go compilers" [] {
  [gc gccgo]
}

def "nu-complete go cover modes" [] {
  [set count atomic]
}

def "nu-complete go module modes" [] {
  [readonly vendor mod]
}

def "nu-complete go vcs modes" [] {
  [auto true false]
}

def "nu-complete go telemetry modes" [] {
  [
    { value: "off", description: "Disable telemetry collection and uploading" }
    { value: "local", description: "Collect telemetry locally without uploading" }
    { value: "on", description: "Enable telemetry collection and uploading" }
  ]
}

def "nu-complete go shuffle modes" [] {
  [off on]
}

def "nu-complete go packages" [context: string, position?: int] {
  let preceding = $context | str substring ..($position | default ($context | str length))
  let token = $preceding | split row --regex '\s+' | last
  let query = match $token {
    "" => "./..."
    $it if ($it | str ends-with "...") => $it
    $it => $"($it)..."
  }

  # Completion should only inspect local source and the module cache.
  let result = with-env { GOPROXY: "off" } {
    do { ^go list -e -f '{{.ImportPath}}{{"\t"}}{{.Doc}}' $query } | complete
  }
  let packages = if $result.exit_code == 0 {
    $result.stdout
    | lines
    | split column --number 2 (char tab) value description
    | where { |row| not ($row.value | str contains "...") }
    | update description { |row|
        if ($row.description | is-empty) { "Go package" } else { $row.description }
      }
  } else {
    []
  }

  [
    { value: ".", description: "Package in the current directory" }
    { value: "./...", description: "All packages below the current directory" }
    { value: "all", description: "All packages in the main module and their dependencies" }
    { value: "cmd", description: "Go repository commands and their internal libraries" }
    { value: "std", description: "All packages in the Go standard library" }
    { value: "tool", description: "Tools declared by the current module" }
  ]
  | append $packages
  | uniq-by value
}

def "nu-complete go files or packages" [context: string, position?: int] {
  let end = $position | default ($context | str length)
  let preceding = $context | str substring ..$end
  let token = $preceding | split row --regex '\s+' | last
  let files = try {
    glob $"($token)*"
    | where { |item|
        let kind = $item | path type
        $kind == "dir" or ($kind == "file" and ($item | str ends-with ".go"))
      }
    | each { |item|
        let kind = $item | path type
        let relative = try { $item | path relative-to $env.PWD } catch { $item }
        {
          value: (if $kind == "dir" { $"($relative)/" } else { $relative })
          description: (if $kind == "dir" { "Directory" } else { "Go source file" })
        }
      }
  } catch {
    []
  }

  let packages = if $position == null {
    nu-complete go packages $context
  } else {
    nu-complete go packages $context $position
  }
  $packages | append $files | uniq-by value
}

def "nu-complete go modules" [] {
  let result = with-env { GOPROXY: "off" } {
    do {
      ^go list -m -e -f '{{.Path}}{{"\t"}}{{if .Version}}{{.Version}}{{else}}main module{{end}}' all
    } | complete
  }

  let modules = if $result.exit_code == 0 {
    $result.stdout
    | lines
    | split column --number 2 (char tab) value description
  } else {
    []
  }

  [{ value: "all", description: "All active modules" }]
  | append $modules
  | uniq-by value
}

def "nu-complete go packages or modules" [context: string, position?: int] {
  let preceding = $context | str substring ..($position | default ($context | str length))
  if ($preceding | split row --regex '\s+' | any { |word| $word in ["-m" "--m"] }) {
    nu-complete go modules
  } else if $position == null {
    nu-complete go packages $context
  } else {
    nu-complete go packages $context $position
  }
}

def "nu-complete go env variables" [context: string, position?: int] {
  let result = do { ^go env -json } | complete
  if $result.exit_code == 0 {
    let preceding = $context | str substring ..($position | default ($context | str length))
    let writing = $preceding | split row --regex '\s+' | any { |word| $word in ["-w" "--w"] }
    $result.stdout
    | from json
    | transpose value current
    | each { |row|
        {
          value: (if $writing { $"($row.value)=" } else { $row.value })
          description: ($row.current | into string)
        }
      }
  } else {
    []
  }
}

def "nu-complete go tools" [] {
  let result = do { ^go tool } | complete
  if $result.exit_code == 0 { $result.stdout | lines } else { [] }
}

def "nu-complete go test names" [] {
  try {
    glob '*_test.go'
    | each { |file|
        open --raw $file
        | lines
        | parse --regex '^\s*func\s+(?<value>(?:Test|Benchmark|Fuzz)\w*)\s*\('
        | each { |row|
            let kind = if ($row.value | str starts-with "Test") {
              "test"
            } else if ($row.value | str starts-with "Benchmark") {
              "benchmark"
            } else {
              "fuzz target"
            }
            { value: $row.value, description: $kind }
          }
      }
    | flatten
    | uniq-by value
  } catch {
    []
  }
}

def "nu-complete go tests" [] {
  nu-complete go test names | where value starts-with "Test"
}

def "nu-complete go benchmarks" [] {
  nu-complete go test names | where value starts-with "Benchmark"
}

def "nu-complete go fuzz targets" [] {
  nu-complete go test names | where value starts-with "Fuzz"
}

def "nu-complete go work modules" [] {
  let result = do { ^go work edit -json } | complete
  if $result.exit_code == 0 {
    $result.stdout
    | from json
    | get -o Use
    | default []
    | each { |entry| { value: $entry.DiskPath, description: $entry.ModulePath } }
  } else {
    []
  }
}

# Go is a tool for managing Go source code.
export extern go [
  command?: string@"nu-complete go commands"
  ...args: string
]

# Start a bug report in the default browser.
export extern "go bug" []

# Compile packages and dependencies.
export extern "go build" [
  -C: path                                   # Change to dir before running the command; must be the first flag
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  --cover                                    # Enable code coverage instrumentation
  --covermode: string@"nu-complete go cover modes" # Set the coverage mode
  --coverpkg: string                         # Apply coverage analysis to matching packages
  -v                                         # Print package names as they are compiled
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --json                                     # Emit build output as JSON
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  -o: path                                   # Write output to this file or directory
  ...packages: string@"nu-complete go files or packages"
]

# Remove object files and cached files.
export extern "go clean" [
  -C: path                                   # Change to dir before running the command
  -i                                         # Remove installed archives or binaries
  -r                                         # Clean dependencies recursively
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  -v                                         # Print package names
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print remove commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --cache                                    # Remove the entire build cache
  --testcache                                # Expire all test results in the build cache
  --modcache                                 # Remove the entire module download cache
  --fuzzcache                                # Remove files stored in the fuzz cache
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  ...packages: string@"nu-complete go packages"
]

# Show documentation for a package or symbol.
export extern "go doc" [
  -C: path                                   # Change to dir before running the command
  --all                                      # Show all documentation for the package
  -c                                         # Respect case when matching symbols
  --cmd                                      # Treat a command like a regular package
  --http                                     # Serve HTML documentation over HTTP
  --short                                    # Show a one-line representation for each symbol
  --src                                      # Show the full source code for the symbol
  -u                                         # Include unexported symbols, methods, and fields
  package_or_symbol?: string@"nu-complete go packages"
  symbol?: string
]

# Print Go environment information.
export extern "go env" [
  --json                                     # Print the environment as JSON
  --changed                                  # Print only values different from their defaults
  -u                                         # Unset defaults previously set with go env -w
  -w                                         # Change default settings using NAME=VALUE arguments
  ...variables: string@"nu-complete go env variables"
]

# Apply fixes suggested by static checkers.
export extern "go fix" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  -x                                         # Print commands as they are executed
  -v                                         # Print package names
  --work                                     # Print and preserve the temporary work directory
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --trimpath                                 # Remove file-system paths from the executable
  --diff                                     # Print a unified diff instead of applying fixes
  --fixtool: path                            # Use an alternative fix tool
  -c: int                                    # Show this many lines of context
  --json                                     # Emit JSON diagnostics and fixes
  --tags: string                             # Comma-separated build tags
  --toolexec: string                         # Program used to invoke toolchain commands
  ...packages: string@"nu-complete go packages"
]

# Reformat package sources with gofmt.
export extern "go fmt" [
  -C: path                                   # Change to dir before running the command
  -n                                         # Print commands without running them
  -x                                         # Print commands as they are executed
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  ...packages: string@"nu-complete go packages"
]

# Generate Go files by processing source directives.
export extern "go generate" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  -v                                         # Print packages and files as they are processed
  -x                                         # Print commands as they are executed
  --work                                     # Print and preserve the temporary work directory
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --run: string                              # Run directives matching this regular expression
  --skip: string                             # Skip directives matching this regular expression
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  ...files_or_packages: string@"nu-complete go files or packages"
]

# Add dependencies to the current module.
export extern "go get" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  -t                                         # Include modules needed to build tests
  -u                                         # Update dependencies to newer minor or patch releases
  --tool                                     # Add matching tool declarations to go.mod
  -v                                         # Print package names
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --json                                     # Emit build output as JSON
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  ...packages: string@"nu-complete go packages"
]

# Show help for a command or topic.
export extern "go help" [
  ...topics: string@"nu-complete go help topics"
]

# Compile and install packages and dependencies.
export extern "go install" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  --cover                                    # Enable code coverage instrumentation
  --covermode: string@"nu-complete go cover modes" # Set the coverage mode
  --coverpkg: string                         # Apply coverage analysis to matching packages
  -v                                         # Print package names as they are compiled
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --json                                     # Emit build output as JSON
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  ...packages: string@"nu-complete go files or packages"
]

# List packages or modules.
export extern "go list" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  --cover                                    # Enable code coverage instrumentation
  --covermode: string@"nu-complete go cover modes" # Set the coverage mode
  --coverpkg: string                         # Apply coverage analysis to matching packages
  -v                                         # Print package names
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  -e                                         # Continue when packages are erroneous
  -f: string                                 # Format output using a Go template
  --json                                     # Print JSON output
  -m                                         # List modules instead of packages
  --compiled                                 # Include files presented to the compiler
  --deps                                     # Include package dependencies
  --export                                   # Include up-to-date export information
  --find                                     # Identify packages without resolving dependencies
  --test                                     # Include test binaries
  -u                                         # Include available module upgrades
  --versions                                 # Include known module versions
  --retracted                                # Include retracted module versions
  --reuse: path                              # Reuse module information from old JSON output
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  ...packages: string@"nu-complete go packages or modules"
]

# Module maintenance.
export extern "go mod" [
  command?: string@"nu-complete go mod commands"
  ...args: string
]

# Download modules to the local cache.
export extern "go mod download" [
  -x                                         # Print commands as they are executed
  --json                                     # Print module information as JSON
  --reuse: path                              # Reuse module information from old JSON output
  ...modules: string@"nu-complete go modules"
]

# Edit go.mod from tools or scripts.
export extern "go mod edit" [
  -C: path                                   # Change to dir before running the command
  -n                                         # Print commands without running them
  -x                                         # Print commands as they are executed
  --fmt                                      # Reformat go.mod without other changes
  --module: string                           # Set the module path
  --go: string                               # Set the expected Go language version
  --toolchain: string                        # Set the suggested Go toolchain
  --godebug: string                          # Add or replace a godebug key=value line
  --dropgodebug: string                      # Drop a godebug key
  --require: string                          # Add a path@version requirement
  --droprequire: string@"nu-complete go modules" # Drop a module requirement
  --exclude: string                          # Add a path@version exclusion
  --dropexclude: string                      # Drop a path@version exclusion
  --replace: string                          # Add an old[@v]=new[@v] replacement
  --dropreplace: string                      # Drop an old[@v] replacement
  --retract: string                          # Add a version retraction
  --dropretract: string                      # Drop a version retraction
  --tool: string                             # Add a tool declaration
  --droptool: string                         # Drop a tool declaration
  --ignore: string                           # Add an ignore declaration
  --dropignore: string                       # Drop an ignore declaration
  --print                                    # Print the final go.mod instead of writing it
  --json                                     # Print the final go.mod as JSON
  go_mod?: path
]

# Print the module requirement graph.
export extern "go mod graph" [
  --go: string                               # Report the graph as loaded by this Go version
  -x                                         # Print commands as they are executed
]

# Initialize a new module in the current directory.
export extern "go mod init" [
  module_path?: string
]

# Add missing and remove unused modules.
export extern "go mod tidy" [
  -e                                         # Continue despite package-loading errors
  -v                                         # Print information about removed modules
  -x                                         # Print download commands
  --diff                                     # Print changes without modifying go.mod or go.sum
  --go: string                               # Update the go directive
  --compat: string                           # Preserve checksums for this Go version
]

# Make a vendored copy of dependencies.
export extern "go mod vendor" [
  -e                                         # Continue despite package-loading errors
  -v                                         # Print vendored modules and packages
  -o: path                                   # Write the vendor tree to this directory
]

# Verify cached dependencies have expected content.
export extern "go mod verify" []

# Explain why packages or modules are needed.
export extern "go mod why" [
  -m                                         # Treat arguments as modules
  --vendor                                   # Exclude tests of dependencies
  ...packages: string@"nu-complete go packages or modules"
]

# Compile and run a Go program.
export extern "go run" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  --cover                                    # Enable code coverage instrumentation
  --covermode: string@"nu-complete go cover modes" # Set the coverage mode
  --coverpkg: string                         # Apply coverage analysis to matching packages
  -v                                         # Print package names as they are compiled
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --json                                     # Emit build output as JSON
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  --exec: string                             # Program used to run the compiled binary
  package: string@"nu-complete go files or packages"
  ...args: string
]

# Manage Go telemetry settings.
export extern "go telemetry" [
  mode?: string@"nu-complete go telemetry modes"
]

# Test packages.
export extern "go test" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  --cover                                    # Enable code coverage instrumentation
  --covermode: string@"nu-complete go cover modes" # Set the coverage mode
  --coverpkg: string                         # Apply coverage analysis to matching packages
  -v                                         # Print tests and verbose test output
  --work                                     # Print and preserve the temporary work directory
  -x                                         # Print commands as they are executed
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --tags: string                             # Comma-separated build tags
  --trimpath                                 # Remove file-system paths from the executable
  --toolexec: string                         # Program used to invoke toolchain commands
  --args                                     # Pass the remaining arguments to the test binary
  -c                                         # Compile the test binary without running it
  --exec: string                             # Program used to run the test binary
  --json                                     # Emit test and build output as JSON
  -o: path                                   # Save a copy of the test binary
  --artifacts                                # Save test artifacts in outputdir
  --bench: string@"nu-complete go benchmarks" # Run benchmarks matching this regular expression
  --benchtime: string                        # Run benchmarks for this duration or iteration count
  --benchmem                                 # Print memory allocation statistics for benchmarks
  --blockprofile: path                       # Write a goroutine blocking profile
  --blockprofilerate: int                    # Set the blocking profile rate
  --count: int                               # Run each test, benchmark, and fuzz seed n times
  --coverprofile: path                       # Write a coverage profile
  --cpu: string                              # Comma-separated GOMAXPROCS values
  --cpuprofile: path                         # Write a CPU profile
  --failfast                                 # Stop starting tests after the first failure
  --fullpath                                 # Show full file names in errors
  --fuzz: string@"nu-complete go fuzz targets" # Run the fuzz target matching this expression
  --fuzztime: string                         # Set total fuzzing time or iteration count
  --fuzzminimizetime: string                 # Set time for each fuzz minimization attempt
  --list: string@"nu-complete go test names" # List matching tests, benchmarks, and fuzz targets
  --memprofile: path                         # Write an allocation profile
  --memprofilerate: int                      # Set the memory profile rate
  --mutexprofile: path                       # Write a mutex contention profile
  --mutexprofilefraction: int                # Set the mutex profile sampling fraction
  --outputdir: path                          # Write profiles and artifacts to this directory
  --parallel: int                            # Maximum number of parallel tests
  --run: string@"nu-complete go tests"       # Run tests matching this regular expression
  --short                                    # Shorten long-running tests
  --shuffle: string@"nu-complete go shuffle modes" # Randomize test and benchmark order
  --skip: string@"nu-complete go test names" # Skip tests matching this regular expression
  --timeout: string                          # Panic if a test binary runs longer than this duration
  --trace: path                              # Write an execution trace
  --vet: string                              # Configure vet checks, or use off to disable vet
  ...packages: string@"nu-complete go packages"
]

# Run a specified Go tool.
export extern "go tool" [
  -C: path                                   # Change to dir before running the command
  -n                                         # Print the command without running it
  --modfile: path                            # Read an alternate go.mod file
  --modcacherw                               # Leave new module-cache directories writable
  --overlay: path                            # Read a JSON build overlay
  command?: string@"nu-complete go tools"
  ...args: string
]

# Print the Go version or binary build information.
export extern "go version" [
  -m                                         # Print embedded module version information
  -v                                         # Report unrecognized files during directory scans
  --json                                     # Print embedded module information as JSON; requires -m
  ...files: path
]

# Report likely mistakes in packages.
export extern "go vet" [
  -C: path                                   # Change to dir before running the command
  -a                                         # Force rebuilding packages that are already up-to-date
  -n                                         # Print commands without running them
  -p: int                                    # Number of build commands that may run in parallel
  --race                                     # Enable data race detection
  --msan                                     # Enable memory sanitizer interoperability
  --asan                                     # Enable address sanitizer interoperability
  -x                                         # Print commands as they are executed
  -v                                         # Print package names
  --work                                     # Print and preserve the temporary work directory
  --asmflags: string                         # Arguments for each go tool asm invocation
  --buildmode: string@"nu-complete go build modes" # Select the build mode
  --buildvcs: string@"nu-complete go vcs modes" # Control VCS stamping
  --compiler: string@"nu-complete go compilers" # Select gc or gccgo
  --gccgoflags: string                       # Arguments for each gccgo invocation
  --gcflags: string                          # Arguments for each go tool compile invocation
  --installsuffix: string                    # Suffix for the package installation directory
  --ldflags: string                          # Arguments for each go tool link invocation
  --linkshared                               # Link against previously created shared libraries
  --mod: string@"nu-complete go module modes" # Set the module download mode
  --modcacherw                               # Leave new module-cache directories writable
  --modfile: path                            # Read an alternate go.mod file
  --overlay: path                            # Read a JSON build overlay
  --pgo: path                                # Set the profile for profile-guided optimization
  --pkgdir: path                             # Install and load packages from this directory
  --trimpath                                 # Remove file-system paths from the executable
  -c: int                                    # Show this many lines of context
  --json                                     # Emit JSON diagnostics
  --fix                                      # Apply the first suggested fix for each diagnostic
  --diff                                     # Print a unified diff instead of applying fixes
  --vettool: path                            # Use an alternative vet tool
  --tags: string                             # Comma-separated build tags
  --toolexec: string                         # Program used to invoke toolchain commands
  ...packages: string@"nu-complete go packages"
]

# Workspace maintenance.
export extern "go work" [
  command?: string@"nu-complete go work commands"
  ...args: string
]

# Edit go.work from tools or scripts.
export extern "go work edit" [
  --fmt                                      # Reformat go.work without other changes
  --go: string                               # Set the expected Go language version
  --toolchain: string                        # Set the Go toolchain to use
  --godebug: string                          # Add or replace a godebug key=value line
  --dropgodebug: string                      # Drop a godebug key
  --use: path                                # Add a module directory
  --dropuse: path@"nu-complete go work modules" # Drop a module directory
  --replace: string                          # Add an old[@v]=new[@v] replacement
  --dropreplace: string                      # Drop an old[@v] replacement
  --print                                    # Print the final go.work instead of writing it
  --json                                     # Print the final go.work as JSON
  go_work?: path
]

# Initialize a workspace file.
export extern "go work init" [
  ...module_directories: path
]

# Sync the workspace build list to its modules.
export extern "go work sync" []

# Add modules to a workspace file.
export extern "go work use" [
  -r                                         # Search recursively for modules
  ...module_directories: path
]

# Make a vendored copy of workspace dependencies.
export extern "go work vendor" [
  -e                                         # Continue despite package-loading errors
  -v                                         # Print vendored modules and packages
  -o: path                                   # Write the vendor tree to this directory
]
