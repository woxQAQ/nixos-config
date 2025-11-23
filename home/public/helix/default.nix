{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.public.neovim;
in
{
  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
    };
  };
}
