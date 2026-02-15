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

    hyprcursor
    # swaybg
    swww
    wayland
    wlr-randr
    #keep-sorted end
  ];
}
