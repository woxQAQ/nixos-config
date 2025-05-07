{
  cmp = {
    enable = false;
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
        {name = "path";}
        {name = "nvim_lsp";}
        {name = "luasnip";}
        {
          name = "buffer";
          # Words from other open buffers can also be suggested.
          option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
          keywordLength = 3;
        }
        {name = "neorg";}
        {
          name = "luasnip";
          keywordLength = 3;
        }
        {name = "nixpkgs_maintainers";}
        {name = "friendly-snippets";}
      ];
    };
  };
  lspkind = {
    enable = true;
    cmp = {
      enable = false;
      menu = {
        nvim_lsp = "[lsp]";
        nvim_lua = "[lua]";
        path = "[path]";
        luasnip = "[snip]";
        buffer = "[buffer]";
        neorg = "[neorg]";
        utilsnips = "[utilsnips]";
        nixpkgs_maintainers = "[nixpkgs]";
        friendly-snippets = "[friendly-snippets]";
      };
    };
  };
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
  cmp-nixpkgs-maintainers.enable = false;
  cmp-nvim-lsp = {
    enable = false; # LSP
  };
  cmp-nvim-lua.enable = false;
  cmp-buffer = {
    enable = false;
  };
  cmp-path = {
    enable = false; # file system paths
  };
  cmp_luasnip = {
    enable = false; # snippets
  };
  cmp-cmdline = {
    enable = false; # autocomplete for cmdline
  };
}
