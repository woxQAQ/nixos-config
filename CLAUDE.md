# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
This is a comprehensive NixOS flake configuration that manages both NixOS and macOS systems. It uses flake-parts for modular configuration and supports multiple hosts including NixOS, WSL, and macOS (Darwin).

## Key Architecture

### Systems Supported
- **x86_64-linux**: NixOS hosts (woxQAQ, wsl)
- **aarch64-darwin**: macOS hosts (woxMac)

### Directory Structure
- `hosts/`: Host-specific configurations
- `home/`: Home-manager configurations organized by platform
- `modules/`: System modules organized by platform
- `lib/`: Custom Nix library functions
- `outputs/`: Flake outputs definitions
- `neovim/`: Neovim configuration using nixvim
- `pkg/`: Custom packages
- `secrets/`: Age-encrypted secrets configuration

### Key Files
- `flake.nix`: Main flake definition with inputs
- `outputs/default.nix`: System configurations using flake-parts
- `lib/mkhost.nix` & `lib/mkDarwin.nix`: Host creation utilities
- `Makefile`: Common development commands

## Commands

### Development
```bash
make fmt              # Format all nix files with alejandra
make bump-flake       # Update flake.lock and format
make repl            # Start nix repl with flake
make shell           # Enter nix shell
```

### System Management
```bash
make switch          # Apply NixOS configuration (woxQAQ)
make switch-wsl      # Apply WSL configuration
make switch-darwin   # Apply macOS configuration
make gc              # Garbage collect nix store
make check-store     # Verify nix store integrity
```

### Hyprland (Linux)
```bash
make waybar-restart  # Restart waybar
```

### macOS Specific
```bash
make darwin-set-proxy  # Set system proxy
make check-brew       # Verify homebrew installation
```

## Formatting
Uses `treefmt` with `alejandra` for nix files. Configuration in `treefmt.toml`.

## Secrets Management
Uses `agenix` for age-encrypted secrets. See `secrets/` directory for configuration.

## Custom Lib Functions
- `scanPath`: Scan directory for .nix files
- `getDir`: Get directory paths
- `mkHost/mkDarwin`: Host creation helpers

## Dependencies
Key flake inputs include:
- nixpkgs (unstable, stable variants)
- home-manager
- nix-darwin
- nixos-wsl
- nixvim
- hyprland
- catppuccin theme system