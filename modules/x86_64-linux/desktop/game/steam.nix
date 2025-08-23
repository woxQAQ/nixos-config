{ pkgs, nix-gaming, ... }:
{
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
    gamemode = {
      enable = true;
    };
    steam = {
      enable = pkgs.stdenv.isx86_64;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      platformOptimizations = true;
    };
  };
}
