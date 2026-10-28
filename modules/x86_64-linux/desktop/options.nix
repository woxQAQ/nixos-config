{ lib, ... }:
with lib;
{
  options.modules.desktop = {
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
