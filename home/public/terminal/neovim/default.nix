{
  woxVim,
  system,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.public.terminal.neovim;
in
{
  options.modules.public.terminal.neovim = {
    enable = lib.mkEnableOption "neovim";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      woxVim.packages.${system}.default
    ];
    home.shellAliases = {
      "vi" = "nvim";
      "vim" = "nvim";
    };
  };
}
