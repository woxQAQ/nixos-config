{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wev
  ];
  fonts.fontconfig.enable = false;
}
