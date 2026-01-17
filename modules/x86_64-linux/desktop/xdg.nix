{ pkgs, ... }:
{
  # xdg = {
  #   autostart = lib.mkDefault true;
  #   menus = lib.mkDefault true;
  #   mine = lib.mkDefault true;
  #   icons = lib.mkDefault true;
  # };
  xdg.portal = {

    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
    ];
    configPackages = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gnome" ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };
  # programs.hyprland.enable = true;
}
