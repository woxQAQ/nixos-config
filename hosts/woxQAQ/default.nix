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
    ../../modules/base.nix
    ../../modules/linux_x86_64
  ];
  networking.hostName = "woxQAQ"; # Define your hostname.
}
