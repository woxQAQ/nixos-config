{ lib, ... }:
with lib;
{
  options.modules.desktop = {
    browser = mkOption {
      type = types.nullOr (
        types.enum [
          "chromium"
          "firefox"
          "zen"
        ]
      );
      default = "firefox";
    };
    fcitx5.enable = mkEnableOption "fcitx5 input method";
    game.enable = mkEnableOption "Gaming";
    environment = mkOption {
      type = types.nullOr (
        types.enum [
          "hyprland"
          "gnome"
          "niri"
        ]
      );
      default = "hyprland";
    };
  };
}
