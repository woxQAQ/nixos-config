{
  programs.nixvim.plugins.lsp = {
    keymaps = {
      silent = true;
      # diagnostic = {
      #   # Navigate in diagnostics
      #   "]e" = "goto_prev";
      #   "[e" = "goto_next";
      # };

      lspBuf = {
        # gd = "definition";
        gD = "references";
        # gt = "type_definition";
        # K = "hover";
        # "<F2>" = "rename";
      };

      extra = [
        {
          action = "<CMD>Lspsaga code_action<CR>";
          key = "<leader>ca";
        }
        {
          action = "<CMD>Lspsaga rename<CR>";
          key = "<leader>cr";
        }
        {
          action = "<CMD>Lspsaga diagnostic_jump_next<CR>";
          key = "]e";
        }
        {
          action = "<CMD>Lspsaga diagnostic_jump_prev<CR>";
          key = "[e";
        }
        {
          action = "<CMD>Lspsaga finder<CR>";
          key = "gr";
        }
        {
          action = "<CMD>Lspsaga finder imp<CR>";
          key = "gi";
        }
        {
          action = "<CMD>Lspsaga peek_definition<CR>";
          key = "gd";
        }
        {
          action = "<CMD>Lspsaga peek_type_definition<CR>";
          key = "gt";
        }
        {
          action = "<CMD>lspsaga hover_doc<CR>";
          key = "K";
        }
      ];
    };
  };
}
