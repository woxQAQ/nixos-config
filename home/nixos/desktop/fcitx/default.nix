{
  pkgs,
  lib,
  osConfig,
  ...
}:
with lib;
let
  cfg = osConfig.modules.desktop.fcitx5;
in
{
  config = mkIf cfg.enable {
    home.file.".local/share/fcitx5/rime/default.custom.yaml".text =
      #yaml
      ''
        patch:
          __include: rime_ice_suggestion:/
          schema_list: 
            - schema: rime_ice
      '';

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "rime";
        };
        "Groups/0/Items/0" = {
          Name = "rime";
          Layout = "";
        };
        "Groups/0/Items/1" = {
          Name = "keyboard-us";
          Layout = "us";
        };
        GroupOrder."0" = "Default";
      };
      fcitx5.addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
          ];
        })
        fcitx5-fluent
        qt6Packages.fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };
}
