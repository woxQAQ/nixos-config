{
  pkgs,
  username,
  ...
}:
{
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  programs.hyprland.enable = true;
  services = {
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "$HOME/.wayland-session";
          user = username;
        };
        default_session = initial_session;
        terminal.vt = 1;
      };
    };
  };
}
