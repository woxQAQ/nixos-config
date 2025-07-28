{ pkgs, unstable-pkg, ... }:
{
  imports = [
    ./hyprland
    ./waypaper.nix
    ./gtk.nix
    ./browsers
    ./game.nix
    # ./qt.nix
    ./xdg.nix
    ./catppuccin.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    mihomo-party
    netease-cloud-music-gtk
    n8n
    aichat
  ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [ pkgs.mpvScripts.mpris ];
  };
}
