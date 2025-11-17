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
      xserver = {
        enable = true;
        desktopManager.gnome = {
          enable = true;
        };
      };
    };
  };
}
