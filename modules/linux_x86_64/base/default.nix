{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./network.nix
    ./system.nix
    ./zram.nix
  ];
}
