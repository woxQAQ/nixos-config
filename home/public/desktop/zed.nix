{
  lib,
  pkgs,
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
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.zed-editor-bin else pkgs.zed-editor;
    };
    xdg.configFile."zed/settings.json".source = mylib.mkMutable dotfilesDir config ./zed.jsonc;
  };
}
