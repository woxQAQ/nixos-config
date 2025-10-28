{ pkgs, ... }:
{
  programs = {
    wlogout.enable = true;
    hyprlock.enable = true;
  };

  catppuccin = {
    waybar.enable = false;
    wlogout.enable = false;
    mako.enable = false;
  };

  services = {
    mako.enable = true;
    hypridle.enable = true;
    swww.enable = true;
  };
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
    # swaybg
    swww
    wayland
    wf-recorder
    wl-clipboard
    wlr-randr
    #keep-sorted end
  ];
}
