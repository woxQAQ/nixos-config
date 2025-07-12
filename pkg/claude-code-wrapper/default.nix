# a wrapper for claude-code to load local environment variables from .env files
{
  stdenv,
  writeShellScriptBin,
  claude-code,
}:
writeShellScriptBin "claude" ''
  #!/bin/bash

  # Cache file for .env files to avoid repeated scanning
  CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/claude-env"
  mkdir -p "$CACHE_DIR" 2>/dev/null || true

  # Function to load environment variables from .env files with caching
  load_env_files() {
    local current_dir="$(pwd)"
    local env_files=(".env" ".env.local" ".env.$(whoami)")
    local cache_key=$(echo -n "$current_dir" | sha256sum | cut -d' ' -f1)
    local cache_file="$CACHE_DIR/env-$cache_key"
    
    # Check if cache exists and is recent (5 minutes)
    if [[ -f "$cache_file" ]] && [[ $(find "$cache_file" -mmin -5 -type f 2>/dev/null) ]]; then
      source "$cache_file" 2>/dev/null || true
      return
    fi

    # Temporary file for new cache
    local temp_cache=$(mktemp)
    
    # Look for .env files in current directory and parent directories
    local found_count=0
    while [[ "$current_dir" != "/" ]] && [[ "$current_dir" != "" ]]; do
      for env_file in "''${env_files[@]}"; do
        local file_path="$current_dir/$env_file"
        if [[ -f "$file_path" ]]; then
          # Only show message for actual files found
          [[ $found_count -eq 0 ]] && echo "Loading environment variables..." >&2
          found_count=$((found_count + 1))
          
          # Process .env file efficiently
          while IFS='=' read -r key value || [[ -n "$key" ]]; do
            if [[ -n "$key" ]] && [[ "$key" != "#"* ]]; then
              # Remove surrounding quotes and whitespace
              value="''${value%\"}"
              value="''${value#\"}"
              value="''${value% }"
              value="''${value# }"
              if [[ -n "$value" ]]; then
                export "$key=$value"
                echo "export $key=''${value//'/\\'}'" >> "$temp_cache"
              fi
            fi
          done < "$file_path"
        fi
      done
      current_dir="$(dirname "$current_dir")"
    done
    
    # Save to cache atomically
    mv "$temp_cache" "$cache_file" 2>/dev/null || rm -f "$temp_cache"
  }

  # Load environment variables from .env files
  load_env_files

  # Execute the actual claude-code with all arguments
  exec ${claude-code}/bin/claude "$@"
''
