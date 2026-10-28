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
  defaultWallpaper = lib.attrByPath [
    "defaultWallpaper"
  ] "wallhaven-6ldd9x.png" hostValues;
in
{
  imports = [
    noctalia.homeModules.default
  ];
  home.packages = with pkgs; [
    qt6Packages.qt6ct
    # required by noctalia's screen-recording plugin
    gpu-screen-recorder
  ];
  programs.noctalia = {
    enable = true;
    settings = {
      wallpaper = {
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        fill_mode = "center";
        default.path = "${config.home.homeDirectory}/.wallpaper/${defaultWallpaper}";
      };
    };
  };
  home.file.".wallpaper/${defaultWallpaper}".source =
    ../../../../assets/${defaultWallpaper};

  xdg.configFile =
    let
      mkMutable = mylib.mkMutable dotfilesDir config;
    in
    {
      "qt6ct/qt6ct.conf".source = mkMutable ./qt6ct.conf;
    };
}
