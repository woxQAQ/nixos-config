{ woxVim, system, ... }:
{
  home.packages = [
    woxVim.packages.${system}.default
  ];
}
