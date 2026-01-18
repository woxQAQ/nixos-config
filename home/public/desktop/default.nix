{
  config,
  lib,
  zed-pkg,
  ...
}:
let
  cfg = config.modules.public.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = zed-pkg.zed-editor;
    };
  };
}
