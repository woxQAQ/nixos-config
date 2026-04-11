{ config, ... }:
{

  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      confPath = "${config.home.homeDirectory}/nixos-config/home/desktop/niri/conf";
    in
    {
      "niri/config.kdl".source = mkSymlink "${confPath}/config.kdl";
      "niri/keybind.kdl".source = mkSymlink "${confPath}/keybind.kdl";
      "niri/noctalia.kdl".source = mkSymlink "${confPath}/noctalia.kdl";
      "niri/windowrules.kdl".source = mkSymlink "${confPath}/windowrules.kdl";
    };
}
