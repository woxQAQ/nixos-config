# Manage repositories embedded in another repository.
export extern "git submodule" [
  --quiet(-q)                    # Only print error messages
  --cached                       # Show the commit recorded in the index
]

# Add a repository as a submodule.
export extern "git submodule add" [
  repository: string             # Repository URL
  path?: path                    # Destination directory
  --branch(-b): string           # Branch to track
  --force(-f)                    # Allow an ignored submodule path
  --name: string                 # Submodule name in .gitmodules
  --reference: path              # Repository to borrow objects from
  --depth: int                   # Create a shallow clone
  --progress                     # Report clone progress
]

# Show submodule status.
export extern "git submodule status" [
  ...paths: path                 # Limit to these submodules
  --cached                       # Show the commit recorded in the index
  --recursive                    # Include nested submodules
]

# Initialize submodule configuration.
export extern "git submodule init" [
  ...paths: path                 # Limit to these submodules
]

# Unregister submodules and remove their working trees.
export extern "git submodule deinit" [
  ...paths: path                 # Limit to these submodules
  --force(-f)                    # Remove working trees with local changes
  --all                          # Unregister all submodules
]

# Clone missing submodules and update their working trees.
export extern "git submodule update" [
  ...paths: path                 # Limit to these submodules
  --init                         # Initialize unregistered submodules
  --recursive                    # Update nested submodules
  --remote                       # Update to the remote tracking branch
  --no-fetch(-N)                 # Skip fetching remote objects
  --force(-f)                    # Force checkout of the recorded commit
  --checkout                     # Check out the recorded commit
  --merge                        # Merge the recorded commit
  --rebase                       # Rebase onto the recorded commit
  --depth: int                   # Limit clone history
  --jobs(-j): int                # Number of submodules cloned in parallel
  --recommend-shallow            # Honor the configured shallow recommendation
  --no-recommend-shallow         # Ignore the configured shallow recommendation
  --reference: path              # Repository to borrow objects from
  --single-branch                # Clone only one branch
  --no-single-branch             # Clone all branches
  --filter: string               # Object filter for partial clones
  --progress                     # Report clone progress
]

# Set the branch tracked by a submodule.
export extern "git submodule set-branch" [
  path: path                     # Submodule path
  --branch(-b): string           # Branch to track
  --default(-d)                  # Track the remote's default branch
]

# Set a submodule's URL and synchronize its configuration.
export extern "git submodule set-url" [
  path: path                     # Submodule path
  newurl: string                 # New repository URL
]

# Summarize changes between submodule commits.
export extern "git submodule summary" [
  ...args: string                # Optional commit and submodule paths
  --cached                       # Compare the index with the recorded commit
  --files                        # Compare the index with the working tree
  --summary-limit(-n): int       # Maximum number of commits to show
]

# Run a shell command in each checked out submodule.
export extern "git submodule foreach" [
  ...command: string             # Shell command to run
  --recursive                    # Include nested submodules
]

# Synchronize submodule URLs from .gitmodules.
export extern "git submodule sync" [
  ...paths: path                 # Limit to these submodules
  --recursive                    # Include nested submodules
]

# Move embedded Git directories into the superproject's Git directory.
export extern "git submodule absorbgitdirs" [
  ...paths: path                 # Limit to these submodules
]
