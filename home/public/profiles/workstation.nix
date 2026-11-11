{ lib, ... }:
{
  imports = [
    ./developer.nix
    ../dev/dbeaver.nix
    ../media.nix
  ];

  modules.public = {
    zed.enable = lib.mkDefault true;
    terminal.emulators = lib.mkDefault [ "kitty" ];
  };
}
