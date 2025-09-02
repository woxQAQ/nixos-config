{
  programs.nixvim = {
    colorschemes = {
      catppuccin = {
        enable = true;
        settings = {
          default_integrations = true;
          # flavour = "mocha";
          background = {
            light = "latte";
            dark = "frappe";
          };
          accent = "pink";
          integrations = {
            # cmp = true;
            gitsigns = true;
            indent_blankline = {
              enable = true;
              colored_indent_levels = true;
            };
            neotree = true;
            treesitter = true;
          };
        };
      };
    };
    plugins = {
      transparent.enable = true;
    };
  };
}
