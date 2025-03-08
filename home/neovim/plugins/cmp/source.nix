{
  programs.nixvim.plugins = {
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
    };
    # cmp-nvim-ultisnips = {
    #   enable = true;
    # };
    friendly-snippets.enable = true;
    cmp-nixpkgs-maintainers.enable = true;
    cmp-nvim-lsp = {
      enable = true; # LSP
    };
    cmp-nvim-lua.enable = true;
    cmp-buffer = {
      enable = true;
    };
    cmp-path = {
      enable = true; # file system paths
    };
    cmp_luasnip = {
      enable = true; # snippets
    };
    cmp-cmdline = {
      enable = true; # autocomplete for cmdline
    };
  };
}
