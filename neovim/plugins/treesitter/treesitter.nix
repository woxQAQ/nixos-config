{
  treesitter = {
    enable = true;
    nixvimInjections = true;
    # folding = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
      autotag.enable = true;
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
      clearOnCursorMove = true;
    };
    smartRename = {
      enable = true;
      keymaps = {
        smartRename = "<leader>cr";
      };
    };
    navigation = {
      enable = true;
    };
  };
  treesitter-context = {
    enable = true;
    settings = {
      max_lines = 4;
      min_window_height = 40;
      multiwindow = true;
      separator = "-";
    };
  };
  hmts.enable = true;
  sleuth.enable = true;
}
