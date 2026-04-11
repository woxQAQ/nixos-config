{ config, pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    config = {
      osc = "no";
      screenshot-format = "webp";
      screenshot-webp-lossless = true;
      screenshot-directory = "${config.home.homeDirectory}/Pictures/Screenshots/mpv";
      screenshot-sw = true;
      wayland-edge-pixels-pointer = 0;
      wayland-edge-pixels-touch = 0;
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      thumbnail
    ];
  };
}
