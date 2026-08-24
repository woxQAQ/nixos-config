# Agent guide

This file provides guidance to coding agents when working with code in this repository.

## Overview

Flake-based NixOS configuration supporting NixOS (x86_64-linux) and macOS (aarch64-darwin). Uses flake-parts for modular organization and Home Manager for user-level configuration.

## Critical Constraint

**You cannot run `nixos-rebuild switch` or `darwin-rebuild switch`.** Ask the user to run these commands instead.

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

Desktop configs live in `home/nixos/desktop/{environment}/`.

### Home Manager Layers

1. Base (`home/nixos/` or `home/darwin/`) - Core shell, terminal, dev tools
2. Public (`home/public/`) - Cross-platform configs
3. Desktop (`home/nixos/desktop/`) - Desktop environment settings
4. Host-specific (`hosts/<hostname>/home.nix`) - Per-machine packages

### Key Patterns

**Multiple nixpkgs inputs**: Different channels for different packages (e.g., `nixpkgs-claude-code`, `nixpkgs-stable`) to allow independent version control.

**Secret management**: Agenix with secrets in separate `secrets` input (private repo).

**Library functions**: `mylib.mkHost` (NixOS), `mylib.mkDarwin` (macOS), `mylib.scanPath`, `mylib.mkMutable`, `mylib.iswsl` in `lib/`.

**Mutable (app-writable) configs**: For config files the application itself rewrites (e.g. noctalia `settings.json`), link them out-of-store with `mylib.mkMutable dotfilesDir config ./settings.json` (a path literal relative to the calling file) instead of a store path. `dotfilesDir` is a special arg pointing at the repo checkout (default `~/nixos-config`, overridable per host via `dotfilesDir` in `hosts/<hostname>/values.nix`). Pure evaluation cannot see these paths, so `home/public/mutable-config.nix` verifies `dotfilesDir` and all symlinks into it at activation time and fails the switch on breakage.
