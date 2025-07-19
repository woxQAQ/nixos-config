{ pkgs, ... }:
{
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
          program = "${pkgs.zsh}/bin/zsh";
          # args = [
          #   "--login"
          #   "-c"
          #   "nu --login --interactive"
          # ];
        };
        osc52 = "CopyPaste";
      };

      scrolling.history = 10000;

      font = {
        normal.family = "Maple Mono NF CN";
        bold.family = "Maple Mono NF CN";
        italic.family = "Maple Mono NF CN";
        bold_italic.family = "Maple Mono NF CN";
        size = if pkgs.stdenv.isDarwin then 14 else 13;
      };
    };
  };
}
