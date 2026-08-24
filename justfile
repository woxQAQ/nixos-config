set shell := ["bash", "-euo", "pipefail", "-c"]

export NIXOS_HOST := env_var_or_default("NIXOS_HOST", "woxQAQ")
export DARWIN_HOST := env_var_or_default("DARWIN_HOST", "woxMac")
export WOXVIM_FLAKE_INPUT := env_var_or_default("WOXVIM_FLAKE_INPUT", "woxVim")
export SECRET_FLAKE_INPUT := env_var_or_default("SECRET_FLAKE_INPUT", "secrets")
export SUBSTITUTERS := env_var_or_default("SUBSTITUTERS", "https://mirrors.ustc.edu.cn/nix-channels/store")
export TRACE := env_var_or_default("TRACE", "0")
export USE_SUBSTITUTERS := env_var_or_default("USE_SUBSTITUTERS", "0")
export OPTIONS := env_var_or_default("OPTIONS", "")
[private]
_os := `uname`
[private]
_nix := if _os == "Darwin" { "nix --extra-experimental-features 'nix-command flakes'" } else { "nix" }

# List available recipes grouped by category.
[group('help')]
list:
    @just --list

alias l := list

# Format all Nix files.
[group('quality')]
fmt:
    {{ _nix }} fmt

# Validate all flake configurations.
[group('quality')]
check: fmt
    {{ _nix }} flake check --keep-going

# Start the Nix REPL.
[group('development')]
repl:
    {{ _nix }} repl

# Enter the default Nix shell.
[group('development')]
shell:
    {{ _nix }} shell

# Update all flake inputs.
[group('updates')]
bump-flake: fmt
    {{ _nix }} flake update --flake .

# Update the secrets flake input.
[group('updates')]
bump-secrets: fmt
    {{ _nix }} flake update "$SECRET_FLAKE_INPUT"

# Update woxVim and switch the current operating system.
[group('updates')]
bump-woxvim: fmt
    #!/usr/bin/env bash
    set -euo pipefail

    {{ _nix }} flake update "$WOXVIM_FLAKE_INPUT"

    if [[ "$OSTYPE" == darwin* ]]; then
      just switch-darwin
    else
      just switch
    fi

alias bump-woxVim := bump-woxvim

# Rebuild and switch the selected NixOS host.
[group('system')]
switch: fmt
    #!/usr/bin/env bash
    set -euo pipefail

    flags=()

    if [[ "$TRACE" == "1" ]]; then
      flags+=(--show-trace)
    fi

    if [[ "$USE_SUBSTITUTERS" == "1" ]]; then
      flags+=(--option substituters "$SUBSTITUTERS")
    fi

    if [[ -n "$OPTIONS" ]]; then
      read -r -a extra_options <<< "$OPTIONS"
      flags+=("${extra_options[@]}")
    fi

    sudo nixos-rebuild switch \
      --flake ".#$NIXOS_HOST" \
      "${flags[@]}"

# Rebuild and switch the WSL host.
[group('system')]
switch-wsl: fmt
    #!/usr/bin/env bash
    set -euo pipefail

    flags=()

    if [[ "$TRACE" == "1" ]]; then
      flags+=(--show-trace)
    fi

    sudo nixos-rebuild switch --flake ".#wsl" "${flags[@]}"

# Rebuild and switch the selected macOS host.
[group('darwin')]
[group('system')]
switch-darwin: fmt
    #!/usr/bin/env bash
    set -euo pipefail

    flags=()

    if [[ "$TRACE" == "1" ]]; then
      flags+=(--show-trace)
    fi

    sudo darwin-rebuild switch \
      --flake ".#$DARWIN_HOST" \
      "${flags[@]}"

# Check Homebrew, installing it when missing.
[group('darwin')]
check-brew:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v brew &>/dev/null; then
      echo "Homebrew installed"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      exit 1
    fi

# Verify and repair the Nix store.
[group('maintenance')]
check-store:
    sudo nix-store --repair --verify --check-contents

# Delete system and user Nix generations older than seven days.
[group('maintenance')]
gc:
    sudo nix-collect-garbage --delete-older-than 7d
    nix-collect-garbage --delete-older-than 7d
