{ config, lib, ... }:
let
  enabled = config.modules.desktop.environment == "niri";
in
{
  config = lib.mkIf enabled {
    programs.niri.enable = true;
  };
}
