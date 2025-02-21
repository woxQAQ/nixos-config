{
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      settings = {
        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        completion = {
          completeopt = "menu,menuone,noinsert";
        };
        experimental = {
          ghost_text = true;
        };
        autoEnableSources = true;
        performance = {
          debounce = 60;
          fetchingTimeout = 200;
          maxViewEntries = 30;
        };
        mapping = {
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.close()";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
        window = {
          completion = {
            border = "solid";
          };
          documentation = {
            border = "solid";
          };
        };
        sources = [
          { name = "path"; }
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          {
            name = "buffer";
            # Words from other open buffers can also be suggested.
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            keywordLength = 3;
          }
          { name = "neorg"; }
          {
            name = "luasnip";
            keywordLength = 3;
          }
          { name = "nixpkgs_maintainers"; }
          { name = "friendly-snippets"; }
        ];
      };
    };
  };
}
