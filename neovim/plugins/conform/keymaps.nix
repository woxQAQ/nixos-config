[
  {
    action.__raw = # lua
      ''
        function()
          require('conform').format({async=true,lsp_format='fallback'})
        end
      '';
    key = "<leader>cf";
    options = {
      silent = true;
      desc = "Format buffer";
    };
  }
]
