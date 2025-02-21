{
  programs.nixvim.plugins = {
    lspkind = {
      enable = true;
      cmp = {
        enable = true;
        menu = {
          nvim_lsp = "[lsp]";
          nvim_lua = "[lua]";
          path = "[path]";
          luasnip = "[snip]";
          buffer = "[buffer]";
          neorg = "[neorg]";
          nixpkgs_maintainers = "[nixpkgs]";
          friendly-snippets = "[friendly-snippets]";
        };
      };
    };
  };
}
