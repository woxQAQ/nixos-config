{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ffmpeg-full
    graphviz
    imagemagick
  ];
}
