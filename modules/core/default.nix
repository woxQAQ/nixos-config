{
  pkgs,
  lib,
  inputs,
  host,
  nur-ryan4yin,
  username,
  ...
}:
{
  imports = [
    ./boot.nix
    ./fonts.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./pipewire.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./system.nix
    ./user.nix
    ./wayland.nix
  ];
}
