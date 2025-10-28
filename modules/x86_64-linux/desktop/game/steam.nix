{
  pkgs,
  nix-gaming,
  osConfig,
  ...
}:
{
  imports = with nix-gaming.nixosModules; [
    pipewireLowLatency
    platformOptimizations
  ];
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

  environment.systemPackages = with pkgs; [
    mangohud
  ];
  programs.lutris = {
    enable = true;
    defaultWinePackage = pkgs.proton-ge-bin;
    steamPackage = osConfig.programs.steam.package;
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

}
