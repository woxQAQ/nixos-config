{
  toggleterm = {
    enable = true;

    settings = {
      size = 20;
      directly = "float";
      float_opts = {
        border = "curved";
        height = 30;
        width = 130;
      };

      shell = "zsh";

      highlights = {
        FloatBorder = {
          link = "Normal";
        };
        NormalFloat = {
          link = "Normal";
        };
        StatusLine = {
          gui = "NONE";
        };
        StatusLineNC = {
          cterm = "italic";
          gui = "NONE";
        };
      };
    };
  };
}
