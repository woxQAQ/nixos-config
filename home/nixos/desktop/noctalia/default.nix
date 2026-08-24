{
  noctalia,
  config,
  pkgs,
  lib,
  mylib,
  dotfilesDir,
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
      mkMutable = mylib.mkMutable dotfilesDir config;
    in
    {
      "noctalia/settings.json".source = mkMutable ./settings.json;
      "qt6ct/qt6ct.conf".source = mkMutable ./qt6ct.conf;
    };
}
