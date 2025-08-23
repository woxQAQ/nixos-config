[
  {
    mode = [
      "v"
      "n"
      "i"
    ];
    action = ":lua require('conform').format({async=true,lsp_format='fallback'})<cr>";
    key = "<leader>cf";
    options = {
      silent = true;
      desc = "Format buffer";
    };
  }
]
