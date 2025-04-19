{
  programs.nixvim = {
    colorschemes = {
      catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          integrations = {
            # cmp = true;
            gitsigns = true;
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
