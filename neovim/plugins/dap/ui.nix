{
  dap-ui = {
    enable = true;

    lazyLoad.settings = {
      before.__raw = ''
        function()
          require('lz.n').trigger_load('nvim-dap', {})
          require('lz.n').trigger_load('nvim-dap-virtual-text', {})
        end
      '';
      keys = [
        {
          __unkeyed-1 = "<leader>du";
          __unkeyed-2.__raw = ''
            function()
              require('dap.ext.vscode').load_launchjs(nil, {})
              require("dapui").toggle()
            end
          '';
          desc = "Toggle Debugger UI";
        }
      ];
    };
  };
}
