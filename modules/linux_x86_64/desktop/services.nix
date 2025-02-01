{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = false;
}
