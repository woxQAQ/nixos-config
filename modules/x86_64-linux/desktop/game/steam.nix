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
      enable = pkgs.stdenv.isx86_64;
    };
    steam = {
      enable = pkgs.stdenv.isx86_64;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      fontPackages = [ pkgs.wqy_zenhei ];
      platformOptimizations.enable = true;
    };
  };

  services.pipewire.lowLatency.enable = true;
  imports = with nix-gaming.nixosModules; [
    pipewireLowLatency
    platformOptimizations
  ];

  environment.systemPackages = with pkgs; [
    mangohud
    lutris
  ];

}
