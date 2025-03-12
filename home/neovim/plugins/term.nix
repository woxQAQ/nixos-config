{
  programs.nixvim = {
    plugins.toggleterm = {
      enable = true;

      settings = {
        size = 20;
        float_opts = {
          border = "curved";
          height = 30;
          width = 130;
        };

        shell = "nu";

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

    keymaps = [
      {
        mode = "n";
        key = "<c-,>";
        action = "<cmd>ToggleTerm<cr>";
        options = {
          desc = "Toggle Terminal Window";
        };
      }
    ];
  };
}
