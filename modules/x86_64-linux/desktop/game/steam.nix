{
  pkgs,
  nix-gaming,
  config,
  lib,
  # aagl,
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
    # aagl.nixosModules.default
  ];
  config = mkIf cfg.enable {
    # programs.anime-game-launcher = {
    #   enable = true;
    #   # package = aagl.anime-game-launcher; # for non-flakes
    #   # package = inputs.aagl.packages.x86_64-linux.anime-game-launcher; # for flakes
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
      gst_all_1.gstreamer
      (pkgs.makeDesktopItem {
        name = "stream-hidpi";
        desktopName = "Steam (HiDPI)";
        exec = "env GDK_SCALE=\"1.5\" steam %U";
        categories = [ "Game" ];
        icon = "steam";
      })
    ];

  };
}
