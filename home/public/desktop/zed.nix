{
  lib,
  fastest-pkg,
  config,
  mylib,
  dotfilesDir,
  ...
}:
let
  cfg = config.modules.public.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = fastest-pkg.zed-editor;
    };
    xdg.configFile."zed/settings.json".source = mylib.mkMutable dotfilesDir config ./zed.jsonc;
  };
}
