# Agent guide

This file provides guidance to coding agents when working with code in this repository.

## Overview

Flake-based NixOS configuration supporting NixOS (x86_64-linux) and macOS (aarch64-darwin). Uses flake-parts for modular organization and Home Manager for user-level configuration.

## Critical Constraint

**You cannot run `nixos-rebuild switch` or `darwin-rebuild switch`.** Ask the user to run these commands instead.

## Build Commands

Run via Makefile:

| Command | Description |
|---------|-------------|
| `make check` | Validate all configurations (run before committing) |
| `make fmt` | Format all Nix files |
| `make bump-flake` | Update all flake inputs |

For debugging: `make switch TRACE=1`

## Architecture

### Host Configuration Pattern

Each host requires two files:
1. `hosts/<hostname>/default.nix` - Machine-specific settings
2. `outputs/<hostname>.nix` - Composes modules into final configuration

### Module System

- `modules/x86_64-linux/` - Linux-specific (system, desktop, packages, boot)
- `modules/aarch64-darwin/` - macOS-specific (system, packages, fonts, brew)
- `modules/public/` - Cross-platform modules

Enable features via options:
```nix
{
  modules.desktop.game.enable = true;
  modules.public.neovim.enable = true;
}
```

### Desktop Environments

Set via `modules.desktop.environment` in host output:
- `hyprland` (default) - Wayland compositor
- `niri` - Scrollable-tiling Wayland
- `gnome` - GNOME desktop

Desktop configs live in `home/desktop/{environment}/`.

### Home Manager Layers

1. Base (`home/nixos/` or `home/darwin/`) - Core shell, terminal, dev tools
2. Public (`home/public/`) - Cross-platform configs
3. Desktop (`home/desktop/`) - Desktop environment settings
4. Host-specific (`hosts/<hostname>/home.nix`) - Per-machine packages

### Key Patterns

**Multiple nixpkgs inputs**: Different channels for different packages (e.g., `nixpkgs-claude-code`, `nixpkgs-stable`) to allow independent version control.

**Secret management**: Agenix with secrets in separate `secrets` input (private repo).

**Library functions**: `mylib.mkHost` (NixOS), `mylib.mkDarwin` (macOS), `mylib.scanPath`, `mylib.iswsl` in `lib/`.
