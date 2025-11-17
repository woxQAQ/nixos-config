{
  lib,
  config,
  ...
}:
let
  enabled = config.modules.desktop.environment == "gnome";
in
{
  config = lib.mkIf enabled {
    services = {
      displayManager.gdm = {
        enable = true;
      };
      desktopManager.gnome = {
        enable = true;
      };
      xserver = {
        enable = true;
      };
    };
  };
}
