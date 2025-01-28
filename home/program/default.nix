{ config, pkgs, ... }:
{
  imports = [
    ./cursor.nix
    ./browsers.nix
    ./common.nix
    ./game.nix
    ./rofi.nix
    ./cloud-native.nix
    ./ide.nix
    ./xdg.nix
    ./gtk.nix
    ./git.nix
  ];
}
