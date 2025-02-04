{
  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
      };
      nix = {
        enable = true;
      };

      lsp = {
        enable = true;

        inlayHints = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "]e" = "goto_prev";
            "[e" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
          };
        };

        servers = {
          clangd.enable = true;
          nil_ls = {
            enable = true;
            settings.formatting.command = [
              "nixfmt"
            ];
          };
          ts_ls.enable = true;
          cssls.enable = true;
          html.enable = true;
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
