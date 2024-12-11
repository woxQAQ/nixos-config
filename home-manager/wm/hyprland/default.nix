{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./vars.nix
    ./config.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    swww
    grim
    slurp
    wl-clip-persist
    cliphist
    wf-recorder
    glib
    wayland
    pamixer
    mako
    wlogout
    swaylock
    swaybg
    wlr-randr
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  xdg.configFile = {
    "hypr/waybar" = {
      source = ./conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ./conf/wlogout;
      recursive = true;
    };
    "hypr/mako" = {
      source = ./conf/mako;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ./scripts;
    };
  };
}
