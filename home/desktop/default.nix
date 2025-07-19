{ pkgs, ... }:
{
  imports = [
    ./hyprland
    ./waypaper.nix
    ./gtk.nix
    ./browsers
    ./game.nix
    ./ide.nix
    ./qt.nix
    ./xdg.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    mihomo-party
  ];
}
