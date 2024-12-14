{ config, pkgs, ... }:
{
  imports = [
    ./vscode.nix
    ./browsers.nix
    ./common.nix
    ./nvim.nix
    ./game.nix
    ./rofi.nix
    ./cloud-native.nix
    ./zed.nix
    ./xdg.nix
    ./gtk.nix
  ];
}