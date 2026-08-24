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
      "niri/config.kdl".source = mkMutable ./config.kdl;
      "niri/keybind.kdl".source = mkMutable ./keybind.kdl;
      "niri/noctalia.kdl".source = mkMutable ./noctalia.kdl;
      "niri/windowrules.kdl".source = mkMutable ./windowrules.kdl;
    };
}
