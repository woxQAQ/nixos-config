{ lib, ... }:
with lib;
{
  options.modules = {
    desktop = {
      browser = mkOption {
        type = types.nullOr (
          types.enum [
            "chromium"
            "firefox"
          ]
        );
        default = "firefox";
      };
      game.enable = mkEnableOption "Gaming";
      fcitx5.enable = mkEnableOption "fcitx5 input method";
      environment = mkOption {
        type = types.nullOr (
          types.enum [
            "hyprland"
            "niri"
            "gnome"
          ]
        );
        default = "hyprland";
      };
    };
  };
}
