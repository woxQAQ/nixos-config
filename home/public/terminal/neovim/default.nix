{ woxVim, system, ... }:
{
  home.packages = [
    woxVim.packages.${system}.default
  ];
  home.shellAliases = {
    "vi" = "nvim";
    "vim" = "nvim";
  };
}
