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
}
