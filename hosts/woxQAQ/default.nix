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
    ../../modules/core
  ];
  networking.hostName = "woxQAQ"; # Define your hostname.
}
