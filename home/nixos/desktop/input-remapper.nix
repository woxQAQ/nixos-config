{
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = osConfig.modules.desktop.game;

  # input-remapper group key for the DualSense (shortest devnode name in the
  # group; hid-playstation groups all four nodes under one phys).
  dualsenseGroup = "Sony Interactive Entertainment DualSense Wireless Controller";
in
{
  config = mkIf cfg.enable {
    xdg.configFile = {
      # input-remapper only reads presets, so a plain store copy is fine.
      "input-remapper-2/presets/${dualsenseGroup}/touchpad-click.json".source =
        ./input-remapper/presets/${dualsenseGroup}/touchpad-click.json;

      # Hotplug autoload: whenever the controller connects, the udev rule
      # asks the daemon to apply this preset for this device group.
      "input-remapper-2/config.json".text = builtins.toJSON {
        autoload = {
          ${dualsenseGroup} = "touchpad-click";
        };
      };
    };
  };
}
