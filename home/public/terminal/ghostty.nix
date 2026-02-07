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
        command = "${pkgs.nushell}/bin/nu --login --interactive";
        background-opacity = "0.93";
        window-colorspace = "display-p3";
        gtk-titlebar = false;
        gtk-single-instance = true;
        confirm-close-surface = false;
      };
    };
  };
}
