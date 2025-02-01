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
    ./game
    ./fonts.nix
    ./pipewire.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./user.nix
    ./wm.nix
  ];
}
