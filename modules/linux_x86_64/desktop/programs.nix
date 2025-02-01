{ pkgs, ... }:
{
  programs = {
    localsend.enable = true;
    dconf.enable = true;
  };
}
