{ config, pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./starship.nix
    ./shell.nix
  ];
}
