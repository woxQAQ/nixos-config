{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.desktop;
in
{
  options.modules = {
    desktop = {
      hyprland.enable = mkEnableOption "Hyprland";
      environment = mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "hyprland"
            "gnome"
          ]
        );
        default = "hyprland";
      };
    };
  };
  imports = [
    ./fcitx
    ./gtk.nix
    ./browsers
    ./game.nix
    ./xdg.nix
    # ./ides.nix
    ./qt.nix
    ./cursor.nix
  ]
  ++ optional cfg.hyprland.enable ./hyprland;
}
