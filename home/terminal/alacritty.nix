{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "none";
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
          # args = [""]
        };
      };

      scrolling.history = 10000;

      font = {
        normal.family = "FiraCode Nerd Font";
        size = 12;
      };

      # draw_bold_text_with_bright_colors = true;
      window.opacity = 0.9;
    };
  };
}
