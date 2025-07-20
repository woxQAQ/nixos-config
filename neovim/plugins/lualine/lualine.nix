{ icons, ... }:
let
  inherit (builtins) readFile;
in

{
  lualine = {
    enable = true;

    settings =
      let
        separators = {
          left = "";
          right = "";
        };
        transparent = {
          a.fg = "none";
          c.bg = "none";
        };
      in
      {
        sections = {
          lualine_a = [
            "mode"
            {
              __unkeyed = "fileformat";
              cond = null;
              padding = {
                left = 1;
                right = 1;
              };
            }
          ];
          lualine_b = [ "encoding" ];
          lualine_c = [
            {
              __unkeyed = "b:gitsigns_head";
              icon = "${icons.git.Branch}";
              color.gui = "bold";
            }
            {
              __unkeyed = "diff";
              source = readFile ./get_diff.lua;
            }
            {
              __unkeyed = "diagnostics";
              sources = {
                __unkeyed = "nvim_diagnostic";
              };
            }
          ];
          lualine_x = [
            {
              color.fg = "#ff9e64";
              # cond = readFile ./noice_has.lua;
              __unkeyed-1.__raw = readFile ./noice_get.lua;
            }
            {
              __unkeyed-1.__raw =
                #lua
                ''
                  function()
                    local msg = ""
                    local buf_ft = vim.api.nvim_buf_get_option(0,"filetype")
                    local clients = vim.lsp.get_active_clients()
                    if next(clients) == nil then
                      return msg
                    end
                    for _, client in ipairs(clients) do
                      local file_types = client.config.filetypes
                      if file_types and vim.fn.index(file_types, buf_ft) ~= -1 then
                        return "lsp: " .. client.name
                      end
                    end
                    return msg
                  end
                '';
            }
            {
              __unkeyed = "filetype";
              cond = null;
              padding = {
                left = 1;
                right = 1;
              };
            }
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
        options = {
          globalstatus = true;
          icons_enable = true;
          always_divide_middle = true;
          component_separators = separators;
          section_separators = separators;
          disabled_filetypes = [
            "Outline"
            "neo-tree"
            "dashboard"
          ];
          theme =
            let
              mode = [
                "normal"
                "insert"
                "visual"
                "replace"
                "command"
                "inactive"
              ];
            in
            builtins.listToAttrs (
              map (_m: {
                name = _m;
                value = transparent;
              }) mode
            );
          extensions = [
            "fzf"
            "neo-tree"
          ];
        };
      };
  };
}
