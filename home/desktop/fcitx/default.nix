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

    # Rime configuration files
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
      fcitx5.addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
          ];
        })
        # rime-ice
        fcitx5-fluent
        qt6Packages.fcitx5-configtool
        fcitx5-gtk
      ];
    };
  };
}
