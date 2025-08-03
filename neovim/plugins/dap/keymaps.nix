[
  {
    mode = "v";
    key = "<leader>de";
    action.__raw = ''
      function() require("dapui").eval() end
    '';
    options = {
      desc = "Evaluate Input";
      silent = true;
    };
  }
  {
    mode = "n";
    key = "<leader>du";
    action.__raw = ''
      function()
        require('dap.ext.vscode').load_launchjs(nil, {})
        require("dapui").toggle()
      end
    '';
    options = {
      desc = "Toggle Debugger UI";
      silent = true;
    };
  }
  {
    mode = "n";
    key = "<leader>dh";
    action.__raw = ''
      function() require("dap.ui.widgets").hover() end
    '';
    options = {
      desc = "Hover";
      silent = true;
    };
  }
  {
    mode = "n";
    key = "<leader>de";
    action.__raw = ''
      function()
        vim.ui.input({ prompt = "Expression: " }, function(expr)
          if expr then require("dapui").eval(expr, { enter = true }) end
        end)
      end
    '';
    options = {
      desc = "Evaluate Input";
      silent = true;
    };
  }
]
