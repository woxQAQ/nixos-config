{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.public.terminal;
in
{
  config = lib.mkIf (cfg.emulator == "foot") {
    programs.foot = {
      enable = pkgs.stdenv.isLinux;
      settings = {
        main = {
          term = "foot";
          font = "${cfg.font.family}:size=${cfg.font.size}";
          dpi-aware = "yes";
          shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
        };
        mouse.hide-when-typing = "yes";
      };
    };
  };
}
