{
  pkgs,
  nix-gaming,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.game;
in
{
  imports = with nix-gaming.nixosModules; [
    pipewireLowLatency
    platformOptimizations
  ];
  config = mkIf cfg.enable {
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
        enable = true;
        dedicatedServer.openFirewall = false;
        gamescopeSession.enable = true;
        protontricks.enable = true;
        extest.enable = true;
        fontPackages = [ pkgs.wqy_zenhei ];
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        platformOptimizations.enable = true;
      };

    };

    services.pipewire.lowLatency.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };
}
