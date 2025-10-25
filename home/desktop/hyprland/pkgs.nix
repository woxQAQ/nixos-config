{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #keep-sorted start
    alsa-utils
    cava
    hyprcursor
    hyprshot
    imv
    networkmanagerapplet
    pavucontrol
    playerctl
    swaybg
    swww
    wayland
    wf-recorder
    wl-clipboard
    #keep-sorted end
  ];
}
