
export def "nu-complete get scripts" [] {
  open package.json
  | get scripts
  #| describe record<start: string, build: string, test: string, eject: string>
  | transpose # to convert the record<start: string, build: string, test: string, eject: string> into a table
  | rename value description
}

export def "nu-complete get deps" [] {
  let packagejson = (open ./package.json)
  let deps = try { $packagejson | get dependencies | columns } catch { [] }
  let devDeps = try { $packagejson | get devDependencies | columns } catch { [] }

  $deps | append $devDeps
}

def "nu-complete pnpm init types" [] {
  ["commonjs" "module"]
}

def "nu-complete pnpm version types" [] {
  [
    { value: "major", description: "Bump 1.2.3 to 2.0.0" }
    { value: "minor", description: "Bump 1.2.3 to 1.3.0" }
    { value: "patch", description: "Bump 1.2.3 to 1.2.4" }
    { value: "premajor", description: "Start the next major prerelease: 1.2.3 to 2.0.0-0" }
    { value: "preminor", description: "Start the next minor prerelease: 1.2.3 to 1.3.0-0" }
    { value: "prepatch", description: "Start the next patch prerelease: 1.2.3 to 1.2.4-0" }
    { value: "prerelease", description: "Advance a prerelease: 1.2.3-0 to 1.2.3-1" }
    { value: "from-git", description: "Use the version from the latest matching Git tag" }
  ]
}

def "nu-complete pnpm" [] {
  [
   # manage your dependencies section
   { value: "add", description: "Installs a package and any packages that it depends on. By default, any new package is installed as a prod dependency" }
   { value: "import", description: "Generates a pnpm-lock.yaml from an npm package-lock.json (or npm-shrinkwrap.json) file" }
   { value: "install", description: "(i) Install all dependencies for a project" }
   { value: "install-test", description: "(it) Runs a pnpm install followed immediately by a pnpm test" }
   { value: "link", description: "(ln) Connect the local project to another one" }
   { value: "prune", description: "Removes extraneous packages" }
   { value: "rebuild", description: "(rb) Rebuild a package" }
   { value: "remove", description: "(rm) Removes packages from node_modules and from the project's package.json" }
   { value: "unlink", description: "Unlinks a package. Like yarn unlink but pnpm re-installs the dependency after removing the external link" }
   { value: "update", description: "(up) Updates packages to their latest version based on the specified range" }
   # review your dependencies section
   { value: "audit", description: "Checks for known security issues with the installed packages" }
   { value: "licenses", description: "Check licenses in consumed packages" }
   { value: "list", description: "(ls) Print all the versions of packages that are installed, as well as their dependencies, in a tree-structure" }
   { value: "outdated", description: "Check for outdated packages" }
   # run your scripts section
   { value: "exec", description: "Executes a shell command in scope of a project" }
   { value: "run", description: "Runs a defined package script" }
   { value: "start", description: "Runs an arbitrary command specified in the package's `start` property of its `scripts` object" }
   { value: "test", description: "(t) Runs a package's `test` script, if one was provided" }
   # others
   { value: "init", description: "Create a package.json file" }
   { value: "pack", description:"" }
   { value: "publish", description:"Publishes a package to the registry" }
   { value: "root", description:"" }
   { value: "store", description:"store add, store path, store prune & store status" }
   { value: "version", description: "Bumps the version of a package" }
  ]
}

export extern "pnpm" [
  command?: string@"nu-complete pnpm"
  --recursive(-r)                    # Run the command for each project in the workspace.
  --help(-h)                         # Print help information
]

export extern "pnpm init" [
  --bare                             # Create a package.json file with the bare minimum of required fields
  --init-package-manager             # Declare a pnpm version range via devEngines.packageManager and auto-download pnpm when it is missing
  --init-type: string@"nu-complete pnpm init types" # Set the module system for the package
  --help(-h)                         # Print help information
]

export extern "pnpm version" [
  newversion?: string@"nu-complete pnpm version types" # The new version or the type of version bump
  --allow-same-version               # Allow bumping to the same version
  --dry-run                          # Print the release plan without applying it
  --filter: string                   # Filter packages by name or glob pattern
  --json                             # Show information in JSON format
  --message: string                  # Set the version commit message
  --no-commit-hooks                  # Skip running Git commit hooks
  --no-git-checks                    # Do not check whether the working tree is clean
  --no-git-tag-version               # Do not create a Git commit or tag
  --preid: string                    # Set the prerelease identifier
  --recursive(-r)                    # Apply the command to all packages in the workspace
  --sign-git-tag                     # Sign the generated Git tag with GPG
  --tag-version-prefix: string       # Set the Git tag prefix
  --help(-h)                         # Print help information
]

export extern "pnpm run" [
  command?: string@"nu-complete get scripts"
  --help(-h)                         # Print help information
]

export extern "pnpm remove" [
  command?: string@"nu-complete get deps"
  --help(-h)                         # Print help information
]

export extern "pnpm add" [
  --help(-h)                         # Print help information
  --save-exact(-E)                   # Install exact version
  --global(-g)                       # Install as a global package
  --recursive(-r)                    #  Run installation recursively in every package found in subdirectories or in every workspace package, when executed inside a workspace. For options that may be used with `-r`, see "pnpm help recursive"
  --save-dev(-D)                     # Save package to your `devDependencies`
  --save-optional(-O)                #  Save package to your `optionalDependencies`
  --save-peer                        #  Save package to your `peerDependencies` and `devDependencies`
  --save-prod(-P)                    #  Save package to your `dependencies`. The default behavior
]
