{
  plugins.lualine = {
    enable = true;
    lazyLoad.settings.event = [
      "VimEnter"
      "BufReadPost"
      "BufNewFile"
    ];

    settings = {
      options = {
        disabledFiletypes = {
          statusline = [
            "startup"
            "alpha"
            "snacks_dashboard"
          ];
        };
        extensions = [
          "fzf"
          "neo-tree"
        ];
        theme = "catppuccin-nvim";
        globalstatus = true;
      };
      sections = {
        lualine_a = [
          {
            __unkeyed-1 = "mode";
            icon = "";
          }
        ];
        lualine_b = [
          {
            __unkeyed-1 = "branch";
            fmt.__raw = ''
              function(name,_)
                return string.sub(name,1,20)
              end  
            '';
            color = {
              gui = "italic,bold";
            };
            icon = "";
          }
          "diff"
        ];
        lualine_c = [
          {
            __unkeyed-1 = "navic";
          }
          {
            __unkeyed-1 = "diagnostics";
            sources = [ "nvim_lsp" ];
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = "󰝶 ";
            };
          }
        ];

        lualine_x = [
          {
            __unkeyed-1 = "filetype";
            icon_only = true;
            separator = "";
            padding = {
              left = 1;
              right = 0;
            };
          }
          {
            __unkeyed-1 = "filename";
            path = 1;
          }
        ];
        lualine_y = [
          {
            __unkeyed-1 = "progress";
          }
        ];
        lualine_z = [
          {
            __unkeyed-1 = "location";
            cond.__raw = ''
              function()
                local cache = {}
                return function()
                  local bufnr = vim.api.nvim_get_current_buf()
                  if cache[bufnr] == nil then
                    local buf_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
                    cache[bufnr] = buf_size < 1024 * 1024 -- 1MB limit
                    -- Clear cache on buffer unload
                    vim.api.nvim_create_autocmd("BufUnload", {
                      buffer = bufnr,
                      callback = function() cache[bufnr] = nil end,
                    })
                  end
                  return cache[bufnr]
                end
              end
            '';
          }
        ];
      };
    };
  };
}
