{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.game;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # snex9x
      # sameboy
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
        wineWowPackages.stagingFull
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
