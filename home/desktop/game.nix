{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.game;
in
{
  options.modules.desktop = {
    game = {
      enable = mkEnableOption "Gaming";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # snex9x
      # sameboy
      gamescope
      hmcl
      winetricks
      prismlauncher
      ryujinx-greemdev
      mgba
    ];
    programs.lutris = {
      enable = true;
      defaultWinePackage = pkgs.proton-ge-bin;
      protonPackages = [ pkgs.proton-ge-bin ];
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
