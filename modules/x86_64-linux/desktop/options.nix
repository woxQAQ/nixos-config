{ lib, ... }:
with lib;
{
  options.modules.desktop = {
    fcitx5.enable = mkEnableOption "fcitx5 input method";
    game = {
      enable = mkEnableOption "Gaming";
      # MAA (Arknights assistant) automation running inside Waydroid.
      # Enabling installs waydroid, adb, maa-assistant-arknights and maa-cli.
      # Usage:
      #   1. Start waydroid, install Arknights inside Android and log in;
      #   2. Run `maa init` and pick the `Waydroid` connection preset —
      #      maa-cli then discovers the device address over adb by itself and
      #      starts/stops the waydroid session around runs;
      #   3. Afterwards `maa run`, `maa fight`, etc. work directly.
      maa.enable = mkEnableOption "MAA (MaaAssistantArknights) automation running on Waydroid";
    };
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
