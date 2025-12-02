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
  config = lib.mkIf (cfg.emulator == "alacritty") {
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          decorations = "none";
          opacity = 0.93;
          dynamic_title = true;
          padding = {
            x = 5;
            y = 5;
          };
          startup_mode = "Maximized";
        };

        terminal = {
          shell = {
            program = "${pkgs.bash}/bin/bash";
            args = [
              "--login"
              "-c"
              "nu --login --interactive"
            ];
          };
          osc52 = "CopyPaste";
        };

        scrolling.history = 10000;

        font = {
          normal.family = cfg.font-family;
          bold.family = cfg.font-family;
          italic.family = cfg.font-family;
          bold_italic.family = cfg.font-family;
          size = cfg.font-size;
        };
      };
    };
  };
}
