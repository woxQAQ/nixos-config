# a wrapper for claude-code to load local environment variables from .env files
{
  writeShellScriptBin,
  claude-code,
}:
writeShellScriptBin "claude"
  #sh
  ''
    #!/usr/bin/env bash

    # Function to load environment variables from .env files
    load_env_files() {
      local current_dir="$(pwd)"
      local env_files=(".env" ".env.local" ".env.claude")

      # Only check current directory, no recursion
      for env_file in "''${env_files[@]}"; do
        if [[ -f "$current_dir/$env_file" ]]; then
          echo "Loading environment from: $current_dir/$env_file" >&2
          # Read and export variables from .env file
          while IFS='=' read -r key value || [[ -n "$key" ]]; do
            if [[ ! -z "$key" && "$key" != "#"* ]]; then
              # Remove surrounding quotes from value if present
              value="''${value%\"}"
              value="''${value#\"}"
              value="''${value%\'}"
              value="''${value#\'}"
              export "$key=$value"
            fi
          done < "$current_dir/$env_file"
        fi
      done
    }

    # Load environment variables from .env files
    load_env_files

    # Execute the actual claude-code with all arguments
    exec ${claude-code}/bin/claude "$@"
  ''
