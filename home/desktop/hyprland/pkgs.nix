{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
