# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a flake-based NixOS configuration that supports both NixOS (x86_64-linux) and macOS (aarch64-darwin) systems. It uses flake-parts for modular organization and Home Manager for user-level configuration management.

## Build Commands

The Makefile provides the primary interface for building and switching configurations:

- `make` or `make switch` - Build and switch NixOS configuration (defaults to `NIXOS_HOST=woxQAQ`)
- `make switch NIXOS_HOST=<hostname>` - Switch to a specific host's configuration
- `make switch-wsl` - Switch WSL configuration
- `make switch-darwin` - Switch nix-darwin configuration
- `make check` - Run flake checks (validates all configurations)
- `make fmt` - Format all Nix files using `nix fmt`
- `make bump-flake` - Update all flake inputs
- `make bump-secrets` - Update only the secrets input
- `make bump-woxVim` - Update the woxVim input and rebuild
- `make bump-claude-code` - Update the nixpkgs-claude-code input and rebuild
- `make gc` - Run garbage collection (deletes generations older than 7 days)
- `make repl` - Open Nix REPL
- `make waybar-restart` - Restart waybar with SIGUSR2

For debugging builds:
- `make switch TRACE=1` - Run switch with `--show-trace` flag

## Architecture

### Directory Structure

```
nixos-config/
├── flake.nix              # Main flake definition with all inputs
├── outputs/               # Flake output definitions (using flake-parts)
│   ├── default.nix        # Main flake-parts config
│   ├── woxQAQ.nix         # Host-specific outputs
│   ├── wsl.nix
│   ├── windows-vm1.nix
│   └── woxDarwin.nix
├── hosts/                 # Machine-specific configurations
│   └── <hostname>/
│       ├── default.nix           # Host config
│       ├── hardware-configuration.nix
│       └── home.nix              # Host-specific home packages
├── home/                  # Home Manager configurations
│   ├── nixos/             # Base NixOS home config
│   ├── darwin/            # Base macOS home config
│   ├── desktop/           # Desktop environment configs
│   └── public/            # Cross-platform configs
├── modules/               # Reusable Nix modules
│   ├── x86_64-linux/      # Linux-specific modules
│   │   ├── system/        # Core system configs
│   │   ├── desktop/       # Desktop environment modules
│   │   ├── packages/      # Package collections
│   │   └── boot/          # Boot configurations
│   └── public/            # Cross-platform modules
├── lib/                   # Custom library functions
│   ├── mkhost.nix         # NixOS host builder
│   ├── mkDarwin.nix       # Darwin host builder
│   └── default.nix        # Library exports
├── pkg/                   # Custom package definitions
├── secrets/               # Agenix secret management
└── overlays/              # Nix overlays
```

### Flake Structure

The configuration uses **flake-parts** with partitions:

1. **dev partition** - Contains development outputs (checks, devShells, formatter)
2. **main flake outputs** - NixOS and Darwin system configurations

**Key Inputs:**
- Multiple `nixpkgs` channels for different purposes:
  - `nixpkgs` - Main unstable channel
  - `nixpkgs-stable` - Stable channel (nixos-25.05)
  - `nixpkgs-darwin` - For nix-darwin
  - `nixpkgs-zed` - For Zed editor
  - `nixpkgs-claude-code` - Separate for Claude Code updates
- `home-manager` - User configuration management
- `agenix` - Secret management
- `nix-darwin` - macOS support
- `nix-gaming` - Gaming-related packages
- Custom inputs: `woxVim`, `secrets`, `noctalia`, `vicinae`

### Host Configuration Pattern

Each host is defined in two places:

1. **Host config** (`hosts/<hostname>/default.nix`) - Machine-specific settings
2. **Flake output** (`outputs/<hostname>.nix`) - Composes the final configuration

The flake output composition follows this pattern:
```nix
{
  # Base NixOS modules
  nixos-modules = [
    inputs.agenix.nixosModules.default
    ../secrets
    ../hosts/${name}
    ../modules/${system}/system
    ../modules/${system}/desktop
    ../modules/${system}/packages
    ../modules/${system}/boot
    ../modules/public
  ];

  # Home Manager modules
  home-modules = [
    ../home/nixos
    ../hosts/${name}/home.nix
    ../home/public
    ../home/desktop
  ];

  # Build with mylib.mkHost
  nixosConfigurations."${name}" = mylib.mkHost (args // {
    inherit nixos-modules home-modules;
    username = name;
  });
}
```

### Desktop Environment System

The configuration supports multiple desktop environments via the `modules.desktop.environment` option:

- **hyprland** - Default Wayland compositor
- **niri** - Scrollable-tiling Wayland compositor
- **gnome** - GNOME desktop environment

Desktop-specific configuration files are in `home/desktop/{environment}/`.

To switch desktop environments for a host, modify the `modules.desktop.environment` value in the host's flake output file.

### Module System

Modules are organized by:
- **Platform**: `x86_64-linux/` vs `aarch64-darwin/` vs `public/`
- **Category**: `system/`, `desktop/`, `packages/`, `boot/`
- **Feature**: Individual modules enable/disable specific features

Example module usage:
```nix
{
  modules.desktop.game.enable = true;
  modules.public.neovim.enable = true;
  modules.desktop.fcitx5.enable = true;
}
```

### Home Manager Structure

Home configurations are layered:

1. **Base** (`home/nixos/` or `home/darwin/`) - Core shell, terminal, dev tools
2. **Public** (`home/public/`) - Cross-platform configs (dev tools, editors)
3. **Desktop** (`home/desktop/`) - Desktop environment settings
4. **Host-specific** (`hosts/<hostname>/home.nix`) - Per-machine packages

### Library Functions

Available in `lib/`:
- `mylib.mkHost` - Build NixOS configuration from modules
- `mylib.mkDarwin` - Build Darwin configuration from modules
- `mylib.scanPath` - Scan directory for .nix files
- `mylib.iswsl` - Check if config is for WSL

### Special Patterns

**Multiple nixpkgs inputs**: Different packages use different nixpkgs inputs to allow independent version control (e.g., `nixpkgs-claude-code` for Claude Code, `nixpkgs-zed` for Zed editor).

**Secret management**: Uses Agenix with secrets in a separate repository (`secrets` input). Each host references its secret files in `secrets/`.

**Custom packages**: Defined in `pkg/` directory and consumed via overlays or direct references.

**Cross-platform support**: The `modules/public/` directory contains modules that work on both Linux and Darwin, enabling shared configuration across systems.

## Common Operations

**Add a new package:**
- System-wide: Add to `modules/x86_64-linux/packages/` or host-specific config
- User-only: Add to `home/public/` or `home/desktop/`

**Add a new host:**
1. Create `hosts/<hostname>/default.nix` with hardware config
2. Create `outputs/<hostname>.nix` composing modules
3. Add entry to `outputs/default.nix` if needed

**Update flake inputs:**
- All: `make bump-flake`
- Specific: `make bump-secrets`, `make bump-woxVim`, etc.

**Check configuration validity:**
- `make check` - Validates all flake outputs
- `nix flake show` - Show available configurations

**Build specific system:**
- `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- For Darwin: `nix build .#darwinConfigurations.<hostname>.system`

## Monitoring

The configuration includes optional system monitoring with Prometheus and Grafana.

**Enable monitoring:**

Set `modules.system.monitoring.enable = true;` in your host's flake output file (e.g., `outputs/<hostname>.nix`).

**Access points:**
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (default credentials: admin/admin)

**Included exporters:**
- node_exporter (port 9100) - System metrics (CPU, memory, disk, network)
- Pre-configured Prometheus datasource in Grafana

**Firewall ports:**
- 3000 - Grafana web interface
- 9090 - Prometheus metrics endpoint
- 9100 - node_exporter metrics

**Security note:** Change the default Grafana admin password after first login. For production, use agenix to manage secrets.

**Optional: Secure Grafana password with agenix:**

The monitoring module supports an optional `grafanaAdminPasswordFile` option for secure password management via agenix:

1. Create encrypted secret:
   ```bash
   openssl rand -base64 32 | nix run github:ryantm/agenix -- --edit secrets/grafana-admin-password.age
   ```

2. Add secret to host's configuration in `outputs/<hostname>.nix`:
   ```nix
   modules.system.monitoring = {
     enable = true;
     grafanaAdminPasswordFile = config.age.secrets.grafana-admin-password.path;
   };

   age.secrets.grafana-admin-password.file = ../secrets/grafana-admin-password.age;
   ```

3. The monitoring module will automatically use the secure password if `grafanaAdminPasswordFile` is set.

**Verification:**

After enabling monitoring and running `make switch`, verify services are running:

```bash
# Check service status
systemctl status prometheus.service
systemctl status prometheus-node-exporter.service
systemctl status grafana.service

# Verify Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'

# Test Grafana health
curl -s http://localhost:3000/api/health | jq
```
