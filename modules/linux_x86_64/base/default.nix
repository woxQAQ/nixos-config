{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./boot
    ./locale.nix
    ./net
    ./system.nix
    ./zram.nix
    ./vm.nix
  ];
}
