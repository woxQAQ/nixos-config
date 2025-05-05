{
  treesitter = {
    enable = true;
    nixvimInjections = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
      autotag.enable = true;
      folding.enable = true;
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
}
