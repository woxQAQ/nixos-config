{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.specified.nix
    ../../modules/base.nix
    ../../modules/linux_x86_64
  ];
  networking.hostName = "woxQAQ"; # Define your hostname.
  hardware.graphics.enable = true;
  system.stateVersion = "24.11";
}
