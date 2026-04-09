{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.public.terminal;
in
{
  config = lib.mkIf (cfg.emulator == "ghostty") {
    programs.ghostty = {
      enable = true;
      settings = {
        inherit (cfg) font-family;
        inherit (cfg) font-size;
        command = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
        background-opacity = "0.93";
        adjust-underline-position = 4;
        window-colorspace = "display-p3";
        window-theme = "ghostty";
        keybind = "alt+backspace=text:\\x1b\\x7f";
        # gtk-titlebar = false;
        gtk-single-instance = true;
        confirm-close-surface = false;
        mouse-hide-while-typing = true;
        mouse-scroll-multiplier = 1;

        gtk-tabs-location = "bottom";
        gtk-wide-tabs = false;
        gtk-toolbar-style = "flat";
        window-padding-y = "2,0";
        window-padding-balance = true;
        window-decoration = false;
      };
    };
  };
}
