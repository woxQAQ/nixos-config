{ pkgs, ... }:
{
  imports = [
    # ./rofi.nix
  ];

  home.packages = with pkgs; [
    pamixer
    go-musicfox
    youtube-tui

    leetgo
    obsidian
    bitwarden-desktop

    # ssh desktop client
    remmina

    font-manager
    qq
    obs-studio
    wineWowPackages.wayland
  ];
}
