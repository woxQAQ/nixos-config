{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkMerge
    mkOption
    types
    ;

  cfg = config.modules.hardware.controllers;

  # hid-playstation exposes the DualSense touchpad as a standalone evdev
  # node (ID_INPUT_TOUCHPAD), which libinput drives as a second pointer.
  # Inside Wine/Lutris games that pointer reads as mouse activity and flips
  # UI prompts/focus. The kernel never reports the touchpad click on the
  # gamepad node, so the click cannot become a controller button without
  # a remapping layer (input-remapper / Steam Input).
  dualsenseTouchpadRemap = pkgs.writeShellScriptBin "dualsense-touchpad-remap" ''
    set -euo pipefail

    group="Sony Interactive Entertainment DualSense Wireless Controller"
    preset="touchpad-click"

    case "''${1:-on}" in
      on)
        exec input-remapper-control --command start --device "$group" --preset "$preset"
        ;;
      off)
        exec input-remapper-control --command stop --device "$group"
        ;;
      *)
        echo "usage: dualsense-touchpad-remap [on|off]" >&2
        exit 2
        ;;
    esac
  '';
in
{
  options.modules.hardware.controllers = {
    xpadneo.enable = mkEnableOption "xpadneo driver for Xbox wireless-over-Bluetooth controllers";
    playstation.enable = mkEnableOption "udev rules for PlayStation DualSense/DualShock controllers";
    playstation.dualsenseTouchpad = mkOption {
      type = types.enum [
        "mouse"
        "remap"
      ];
      default = "mouse";
      description = ''
        How the DualSense touchpad node is handled.
        - "mouse": kernel default, the touchpad acts as a pointer on desktop
          (and leaks into games as mouse activity).
        - "remap": input-remapper grabs the controller so the touchpad click
          reaches games as a gamepad button (BTN_SOUTH) and the pointer
          noise disappears. Enable per-session with
          `dualsense-touchpad-remap`; while active the touchpad cannot act
          as a desktop pointer either.
      '';
    };
    joycon.enable = mkEnableOption "joycond support for Nintendo Joy-Con/Switch Pro controllers";
  };

  config = mkMerge [
    (mkIf cfg.xpadneo.enable {
      hardware.xpadneo.enable = true;
    })
    (mkIf cfg.playstation.enable {
      services.udev.packages = [ pkgs.game-devices-udev-rules ];
      environment.systemPackages = [ dualsenseTouchpadRemap ];
    })
    (mkIf (cfg.playstation.enable && cfg.playstation.dualsenseTouchpad == "remap") {
      # The injection daemon grabs the DualSense evdev group and creates the
      # virtual BTN_SOUTH device; user preset lives in home-manager
      # (desktop/input-remapper.nix). The udev autoload rule fires on
      # hotplug, and the user-session registration unit (see
      # dualsense-autoload-user.service below) tells the root daemon which
      # user config dir to read, so the touchpad remap attaches
      # automatically whenever the controller connects.
      services.input-remapper.enable = true;
      services.input-remapper.enableUdevRules = true;

      # The root daemon only reads a user's config after that user session
      # told it about the config dir (set_config_dir over dbus, see
      # Daemon.connect in input-remapper's daemon.py). No GUI runs here, so
      # register it with a one-shot unit at login instead.
      systemd.user.services.dualsense-autoload-user = {
        description = "Register user config dir with input-remapper daemon";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.input-remapper}/bin/input-remapper-control --command hello";
          # the daemon may still be starting during early login
          Restart = "on-failure";
          RestartSec = 3;
        };
      };
    })
    (mkIf cfg.joycon.enable {
      services.joycond.enable = true;
    })
  ];
}
