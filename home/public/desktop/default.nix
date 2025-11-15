{ config, lib, ... }:
let
  cfg = config.modules.public.desktop;
in
{
  options.modules.public.desktop = {
    enable = lib.mkEnableOption "Desktop";
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
    };
  };
}
