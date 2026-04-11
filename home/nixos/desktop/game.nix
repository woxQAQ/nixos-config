{
  pkgs,
  lib,
  osConfig,
  ...
}:
with lib;
let
  cfg = osConfig.modules.desktop.game;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dualsensectl
      gamescope
      hmcl
      winetricks
      prismlauncher
      evtest
      ryubing
      mgba
      bbe
      umu-launcher
      protonplus
      mangohud
    ];

    programs.lutris = {
      enable = true;
      defaultWinePackage = pkgs.proton-ge-bin;
      protonPackages = [ pkgs.proton-ge-bin ];
      steamPackage = osConfig.programs.steam.package;
      winePackages = with pkgs; [
        wineWow64Packages.full
        wineWow64Packages.stagingFull
      ];
      extraPackages = with pkgs; [
        winetricks
        gamescope
        gamemode
        mangohud
        umu-launcher
      ];
    };
  };
}
