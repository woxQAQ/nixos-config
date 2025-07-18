{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        # decorations = "none";
        dynamic_padding = true;
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
      };

      scrolling.history = 10000;

      font = {
        normal.family = "Maple Mono NF CN";
        bold = {
          style = "Bold";
        };
        size = 15;
      };

      window.opacity = 0.93;
    };
  };
}
