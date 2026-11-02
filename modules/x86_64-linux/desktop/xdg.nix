{ pkgs, lib, ... }:
let
  termDesktop = [
    "com.mitchellh.ghostty.desktop"
    "kitty.desktop"
  ];
in
{
  xdg = {
    autostart.enable = lib.mkDefault true;
    menus.enable = lib.mkDefault true;
    mime.enable = lib.mkDefault true;
    icons.enable = lib.mkDefault true;
  };
  xdg.terminal-exec = {
    enable = true;
    package = pkgs.xdg-terminal-exec;
    settings = {
      GNOME = termDesktop ++ [
        "org.gnome.Terminal.desktop"
      ];
      niri = termDesktop;
      default = termDesktop;
    };
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
    ];
    config = {
      common = {
        default = [
          "gtk"
          "gnome"
        ];
      };

      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Clipboard" = [ "gnome" ];
      };
      niri = {
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Clipboard" = "gnome";
      };
    };
  };
  # programs.hyprland.enable = true;
}
