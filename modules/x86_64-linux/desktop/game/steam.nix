{ pkgs, nix-gaming, ... }:
{
  # boot.kernel.sysctl = {
  #   "vm.max_map_count" = 2147483642;
  # };
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
      extraCompatPackages = [ pkgs.proton-ge-bin ];
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
