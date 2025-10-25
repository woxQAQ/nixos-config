{ pkgs, ... }:
{
  imports = [
    ./hyprland
    ./waypaper.nix
    ./gtk.nix
    ./browsers
    ./game.nix
    ./xdg.nix
    ./ides.nix
    # ./catppuccin.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    # mihomo-party
    clash-nyanpasu
    netease-cloud-music-gtk
    n8n
    insomnia
    notepad-next
  ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [ pkgs.mpvScripts.mpris ];
  };
}
