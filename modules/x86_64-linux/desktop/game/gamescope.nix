{ config, lib, ... }:
let
  cfg = config.modules.desktop.game;
in
{
  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
    programs.steam.gamescopeSession.enable = true;
  };
}
