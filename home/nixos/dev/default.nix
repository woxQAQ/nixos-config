{ pkgs, ... }:
{
  home.package = with pkgs; [
    dbeaver-bin
  ];
}
