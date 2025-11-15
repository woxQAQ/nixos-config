{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clash-nyanpasu
    netease-cloud-music-gtk
    n8n
    insomnia
    notepad-next

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
