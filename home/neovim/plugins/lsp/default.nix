{
  imports = [
    ./keymaps.nix
    ./lspsaga.nix
    ./refactor.nix
  ];
  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };
      nix = {
        enable = true;
      };

      colorizer = {
        enable = true;
        settings.user_default_options.css = true;
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          clangd.enable = true;
          nil_ls = {
            enable = true;
            settings.formatting.command = [
              "nixfmt"
            ];
          };
          pylsp.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;
          cssls.enable = true;
          html.enable = true;
          statix.enable = true;
          jsonls.enable = true;
          gopls = {
            enable = true;
            autostart = true;
          };
          yamlls.enable = true;
        };
      };
    };
  };
}
