{ pkgs, ... }:
{
  programs.dbeaver = {
    enable = true;
    drivers = with pkgs; [ sqlite-jdbc ];
  };
}
