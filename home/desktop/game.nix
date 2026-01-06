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
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # snex9x
      # sameboy
      gamescope
      hmcl
      winetricks
      prismlauncher
      ryubing
      mgba
    ];

    systemd.user.services.win11-steamapps-symlink = {
      Unit = {
        Description = "Create symlink to Windows Steam library";
        After = [ "mnt-win11.mount" ];
        Requires = [ "mnt-win11.mount" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/ln -sf \"/mnt/win11/Program Files (x86)/Steam\" %h/win11-steamapps";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

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
