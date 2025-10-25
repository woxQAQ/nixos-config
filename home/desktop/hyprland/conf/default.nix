{ config, ... }:
{
  xdg.configFile =
    let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      hyprPath = "${config.home.homeDirectory}/nixos-config/home/desktop/hyprland/conf";
    in
    {
      "waybar".source = mkSymlink "${hyprPath}/waybar";
      "wlogout".source = mkSymlink "${hyprPath}/wlogout";
      "mako".source = mkSymlink "${hyprPath}/mako";
      "hypr/configs".source = mkSymlink "${hyprPath}/hypr";
    };
}
