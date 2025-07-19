{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "gtk"
          "hyprland"
        ];
      };
    };
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
