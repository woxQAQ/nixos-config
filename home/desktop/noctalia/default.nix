{
  noctalia,
  config,
  pkgs,
  lib,
  hostValues,
  ...
}:
let
  inherit (hostValues) defaultWallpaper;
in
{
  imports = [
    noctalia.homeModules.default
  ];
  home.packages = with pkgs; [
    qt6Packages.qt6ct
    app2unit
    gpu-screen-recorder
  ];
  programs.noctalia-shell = {
    enable = true;
  };
  home.file.".wallpaper/${defaultWallpaper}".source = ../../../assets/${defaultWallpaper};

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nixos-config/home/desktop/noctalia";
    in
    {
      "noctalia/settings.json".source = mkSymlink "${confPath}/settings.json";
    };
  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell - Wayland desktop shell";
      Documentation = "https://docs.noctalia.dev/docs";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = lib.getExe pkgs.noctalia-shell;
      Restart = "on-failure";

      Environment = [
        "QT_QPA_PLATFORM=wayland;xcb"
        "QT_QPA_PLATFORMTHEME=qt6ct"
        "QT_AUTO_SCREEN_SCALE_FACTOR=1"
      ];
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
