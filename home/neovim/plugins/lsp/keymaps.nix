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
          options.desc = "code action";
        }
        {
          action = "<CMD>Lspsaga rename<CR>";
          key = "<leader>cr";
          options.desc = "rename";
        }
        # {
        #   action = "<CMD>Lspsaga diagnostic_jump_next<CR>";
        #   key = "]e";
        # }
        # {
        #   action = "<CMD>Lspsaga diagnostic_jump_prev<CR>";
        #   key = "[e";
        # }
        {
          action = "<CMD>Lspsaga finder<CR>";
          key = "gr";
          options.desc = "find references";
        }
        {
          action = "<CMD>Lspsaga finder imp<CR>";
          key = "gi";
          options.desc = "find implement";
        }
        {
          action = "<CMD>Lspsaga peek_definition<CR>";
          key = "gd";
          options.desc = "find definition";
        }
        {
          action = "<CMD>Lspsaga peek_type_definition<CR>";
          key = "gt";
          options.desc = "find type definition";
        }
        {
          action = "<CMD>lspsaga hover_doc<CR>";
          key = "K";
          options.desc = "hover doc";
        }
      ];
    };
  };
}
