{ pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./security.nix
    ./system.nix
    ./user.nix
    ./brew.nix
  ];
  nix.package = pkgs.lix;
}
