{ config, lib, ... }:
let
  enabled = config.modules.desktop.environment == "niri";
in
{
  config = lib.mkIf enabled {
    programs.niri.enable = true;
    # External monitor brightness is controlled over DDC/CI via I²C.
    hardware.i2c.enable = true;
  };
}
