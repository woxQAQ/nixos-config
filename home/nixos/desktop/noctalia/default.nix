{
  noctalia,
  config,
  pkgs,
  lib,
  hostValues ? { },
  ...
}:
let
  defaultWallpaper = lib.attrByPath [ "defaultWallpaper" ] "wallhaven-6ldd9x.png" hostValues;
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
  home.file.".wallpaper/${defaultWallpaper}".source = ../../../../assets/${defaultWallpaper};

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nixos-config/home/desktop/noctalia";
    in
    {
      "noctalia/settings.json".source = mkSymlink "${confPath}/settings.json";
      "qt6ct/qt6ct.conf".source = mkSymlink "${confPath}/qt6ct.conf";
    };
}
