[
  {
    action.__raw = ''
      function()
        require("conform").format()
      end
    '';
    key = "<leader>cf";
    options = {
      silent = true;
      desc = "Format buffer";
    };
  }
]
