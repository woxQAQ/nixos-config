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
