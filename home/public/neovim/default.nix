{
  woxVim,
  system,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.public.neovim;
in
{
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
