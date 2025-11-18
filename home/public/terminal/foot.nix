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
  config = lib.mkIf (cfg == "foot") {
    programs.foot = {
      enable = pkgs.stdenv.isLinux;
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
  };
}
