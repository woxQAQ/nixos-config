{pkgs, ...}: {
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
          program = "${pkgs.bash}/bin/bash";
          args = [
            "--login"
            "-c"
            "nu --login --interactive"
          ];
        };
      };

      scrolling.history = 10000;

      font = {
        normal.family = "Hack Nerd Font Mono";
        bold = {
          style = "Bold";
        };
        size = 12;
      };

      window.opacity = 0.93;
    };
  };
}
