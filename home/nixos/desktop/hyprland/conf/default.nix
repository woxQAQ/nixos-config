{
  config,
  mylib,
  dotfilesDir,
  ...
}:
{
  xdg.configFile =
    let
      mkMutable = mylib.mkMutable dotfilesDir config;
    in
    {
      "waybar".source = mkMutable ./waybar;
      "wlogout".source = mkMutable ./wlogout;
      "mako".source = mkMutable ./mako;
      "hypr/configs".source = mkMutable ./hypr;
    };
}
