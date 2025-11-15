{
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop;
in
{
  options.modules = {
    desktop = {
      fcitx5.enable = mkEnableOption "fcitx5 input method";
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile = {
      "fcitx5/profile" = {
        source = ./profile.conf;
        force = true;
      };
    };
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };
}
