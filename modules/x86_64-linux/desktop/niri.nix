{ config, lib, ... }:
let
  enabled = config.modules.desktop.environment == "gnome";
in
{
  config = lib.mkIf enabled {
    programs.niri.enable = true;
  };
}
