{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ups
    glow
  ];
}
