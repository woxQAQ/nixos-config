{ woxVim, system, ... }:
{
  home.packages = [
    woxVim.packages.${system}.default
  ];
  home.shellAliases = {
    "vi" = "neovim";
    "vim" = "neovim";
  };
}
