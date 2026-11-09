# Catppuccin appearance integration

This module extends the pinned `catppuccin/nix` input without vendoring its source. It reuses the upstream global module, source packages, port options, and static configurations. The upstream port list is filtered to replace only the ports in `ports.nix`; their original options and imports are retained by `overrides.nix`.

```nix
catppuccin = {
  enable = true;
  autoEnable = true;
  appearance = "auto";
  lightFlavor = "latte";
  flavor = "mocha";

  # Ports can opt out or select a different dark flavor.
  btop.appearance = "static";
  helix.flavor = "frappe";
};
```

`appearance` is `static` by default. Setting it to `auto` enables the extensions below. Each extended port inherits the global `appearance` and `lightFlavor`; its existing `flavor` option selects its dark theme. Ports outside this list retain upstream behavior. The existing enable and accent options continue to apply.

| Ports                                                     | Mechanism                                                               |
| --------------------------------------------------------- | ----------------------------------------------------------------------- |
| bat, Ghostty, Helix, Yazi, Zellij                         | Native light/dark theme selection from the terminal or desktop          |
| Atuin, btop, delta, eza, fzf, k9s, lazygit, Nushell, tmux | Linux desktop setting selects a bundle of upstream Catppuccin resources |

## Desktop setting bridge

On Linux, `catppuccin-appearance.service` monitors `org.gnome.desktop.interface color-scheme` through GSettings. Noctalia already publishes its resolved appearance to this setting when `theme.sync_color_scheme = true`. The service uses that result; it does not calculate a separate schedule or change desktop settings.

Both bundles are built ahead of time. `catppuccin-apply` atomically replaces `$XDG_CONFIG_HOME/catppuccin/current` under a lock, so all clients resolve the same generation. Home Manager initializes the link after linking the new configuration at activation, and the service reconciles it when the graphical session starts. GSettings schemas and the dconf backend are included explicitly. Configurations that include or link a theme continue to be managed by Home Manager; the appearance service only owns its `current` link and lock file.

- btop reloads through SIGUSR2; tmux reloads the Catppuccin plugin on its default server.
- An existing Nushell process checks the bundle at each prompt and applies the pre-parsed light or dark configuration when needed.
- Atuin, delta, eza, fzf, k9s, and lazygit use the selected resource when they next load their configuration. An already open TUI may require reopening. Cluster-specific k9s skin overrides still take precedence.
- Alternate tmux sockets are not reloaded by the service.
- Programs using native detection require the terminal and any intervening multiplexer to propagate appearance notifications.

On macOS, the native integrations work the same way. The GSettings bridge is Linux-only; its ports retain their upstream static configuration on macOS. Adding a macOS event source can reuse the same bundle design later.

Do not enable Noctalia's btop template alongside the btop port: both would own its theme selection. Applications such as tuios that already maintain a mutable configuration keep their native theme pair in that application-owned file; catppuccin/nix has no tuios port to replace.

## Maintenance and verification

The adapter depends on three upstream internal interfaces: `modules/global.nix`, `modules/home-manager/all-modules.nix`, and the two-stage port module functions. The flake lock pins these interfaces. After updating the input, run the integration check before switching. Missing port files, changed option contracts, or broken resource paths should fail evaluation or the check instead of silently reverting to another palette.

The check evaluates full Home Manager configurations for automatic, static, disabled, and mixed policies. In the build sandbox it switches real theme bundles, verifies that assets exist, changes a running Nushell's palette, and exercises the watcher using an isolated GSettings keyfile backend. It does not access the user's desktop settings.

```nu
nix build '.#checks.x86_64-linux.catppuccin-appearance' --no-link
```
