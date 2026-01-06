{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.fcitx5;
in
{
  config = mkIf cfg.enable {
    home.file.".config/fcitx5/profile" = {
      source = ./profile.conf;
      force = true;
    };
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };
}
