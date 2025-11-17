{ lib, ... }:
with lib;
{
  options.modules = {
    desktop = {
      game.enable = mkEnableOption "Gaming";
      environment = mkOption {
        type = types.nullOr (
          types.enum [
            "hyprland"
            "gnome"
          ]
        );
        default = "hyprland";
      };
    };
  };
}
