{ pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./security.nix
    ./system.nix
    ./user.nix
    ./brew.nix
    ./packages.nix
  ];
}
