{ pkgs, ... }:
{
  home.packages = with pkgs; [
    eww
    swww
    slurp
    hyprcursor
    wl-clip-persist
    cliphist
    wf-recorder
    glib
    weston
    wayland
    imv
    pamixer
    hyprshot
    swaylock
    swaybg
    wlr-randr
    alsa-utils
    networkmanagerapplet
  ];
}
