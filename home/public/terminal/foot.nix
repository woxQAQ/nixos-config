{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "foot";
        font = "Maple Mono NF CN:size=14";
        dpi-aware = "yes";
        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };
      mouse.hide-when-typing = "yes";
    };
  };
}
