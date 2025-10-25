{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cava
    hyprcursor
    wl-clipboard

    wf-recorder
    wayland
    imv

    hyprshot
    swaybg
    pavucontrol
    playerctl

    alsa-utils
    networkmanagerapplet
  ];
}
