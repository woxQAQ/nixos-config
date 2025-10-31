{ config, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop";
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
    };
  };
}
