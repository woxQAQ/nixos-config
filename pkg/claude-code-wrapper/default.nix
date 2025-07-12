{
  stdenv,
  writeShellScriptBin,
  claude-code,
}:
writeShellScriptBin "claude" ''
  #!/bin/bash

  # Function to load environment variables from .env files
  load_env_files() {
    local current_dir="$(pwd)"
    local env_files=(".env" ".env.local" ".env.$(whoami)")

    # Look for .env files in current directory and parent directories
    while [[ "$current_dir" != "/" ]]; do
      for env_file in "''${env_files[@]}"; do
        if [[ -f "$current_dir/$env_file" ]]; then
          echo "Loading environment from: $current_dir/$env_file" >&2
          # Read and export variables from .env file
          while IFS='=' read -r key value; do
            if [[ ! -z "$key" && "$key" != "#"* ]]; then
              # Remove surrounding quotes from value if present
              value="''${value%\"}"
              value="''${value#\"}"
              export "$key=$value"
            fi
          done < "$current_dir/$env_file"
        fi
      done
      current_dir="$(dirname "$current_dir")"
    done
  }

  # Load environment variables from .env files
  load_env_files

  # Execute the actual claude-code with all arguments
  exec ${claude-code}/bin/claude "$@"
''
