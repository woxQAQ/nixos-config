{
  programs.nixvim.plugins.lsp = {
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
  };
}
