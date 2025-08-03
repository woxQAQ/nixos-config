{
  treesitter = {
    enable = true;
    nixvimInjections = true;
    folding = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
      autotag.enable = true;
      folding.enable = true;
      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = "gnn";
          node_incremental = "grn";
          scope_incremental = "grc";
          node_decremental = "grm";
        };
      };
    };

  };

  treesitter-refactor = {
    enable = true;
    highlightDefinitions = {
      enable = true;
      # Set to false if you have an `updatetime` of ~100.
      clearOnCursorMove = false;
    };
  };
  hmts.enable = true;
  sleuth.enable = true;
}
