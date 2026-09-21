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
[private]
_nixos_hosts := "woxQAQ wsl windows-vm1 selfcloud"
[private]
_darwin_hosts := "woxMac woxMac-m1"

# Rebuild and switch the host saved by select-host.
[group('system')]
rebuild:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ ! -s host ]]; then
      just select-host
    fi

    selected_host=$(cat host)
    for candidate in {{ _nixos_hosts }}; do
      if [[ "$selected_host" == "$candidate" ]]; then
        exec env NIXOS_HOST="$selected_host" just switch
      fi
    done
    for candidate in {{ _darwin_hosts }}; do
      if [[ "$selected_host" == "$candidate" ]]; then
        exec env DARWIN_HOST="$selected_host" just switch-darwin
      fi
    done

    echo "Unknown host '$selected_host'. Run 'just select-host' again." >&2
    exit 1

# Select a host interactively, or save the supplied host name.
[group('system')]
select-host selected="":
    #!/usr/bin/env bash
    set -euo pipefail

    hosts=({{ _nixos_hosts }} {{ _darwin_hosts }})
    selected_host={{ quote(selected) }}
    if [[ -z "$selected_host" ]]; then
      PS3="Select host: "
      select selected_host in "${hosts[@]}"; do
        if [[ -n "$selected_host" ]]; then
          break
        fi
        echo "Choose a number from the list." >&2
      done
    fi

    for candidate in "${hosts[@]}"; do
      if [[ "$selected_host" == "$candidate" ]]; then
        printf '%s\n' "$selected_host" > host
        echo "Selected host: $selected_host"
        exit 0
      fi
    done

    echo "No valid host selected; host file unchanged." >&2
    exit 1

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

# Update woxVim and switch the saved host.
[group('updates')]
bump-woxvim: fmt
    #!/usr/bin/env bash
    set -euo pipefail

    {{ _nix }} flake update "$WOXVIM_FLAKE_INPUT"

    just rebuild

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
    sudo nix-collect-garbage
