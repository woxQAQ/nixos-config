{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    iproute2mac
    coreutils
  ];
}
