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

      ts-autotag = {
        enable = true;
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          clangd.enable = true;
          nil_ls = {
            enable = true;
            settings.formatting.command = [
              "alejandra"
            ];
          };
          pylsp.enable = true;
          pyright.enable = true;
          ts_ls = {
            enable = true;
            settings.formatting.command = [
              "prettier"
            ];
          };
          cssls = {
            enable = true;
            filetypes = ["css" "scss" "less"];
          };
          html.enable = true;
          statix.enable = true;
          rust_analyzer.enable = true;
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
