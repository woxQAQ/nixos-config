{ lib, pkgs, ... }:
{
  plugins = {
    direnv.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
    nix.enable = lib.mkDefault true;
    nix-develop.enable = lib.mkDefault true;
  };
}
