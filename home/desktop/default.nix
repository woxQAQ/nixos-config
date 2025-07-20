{ pkgs, ... }:
{
  imports = [
    ./hyprland
    ./waypaper.nix
    ./gtk.nix
    ./browsers
    ./game.nix
    ./ide.nix
    # ./qt.nix
    ./xdg.nix
    ./catppuccin.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    mihomo-party
  ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = [ pkgs.mpvScripts.mpris ];
  };
}
