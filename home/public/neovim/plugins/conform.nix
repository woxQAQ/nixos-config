{
  plugins.conform-nvim = {
    enable = true;
    autoInstall = {
      enable = true;
    };
    lazyLoad.settings = {
      cmd = [
        "ConformInfo"
      ];
      event = [ "BufWritePre" ];
    };
    settings = {
      formatters_by_ft = rec {
        go = [ "golines" ];
        nix = [ "nixfmt" ];
        rust = [ "rustfmt" ];
        javascript = [ "biome" ];
        typescript = javascript;
        "_" = [
          "squeeze_blanks"
          "trim_whitespace"
          "trim_newlines"
        ];
      };
      format_on_save = /* lua */ ''
        function(bufnr)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("/node_modules/") or bufname:match("/.direnv/") then
            return
          end

          local function on_format(err)
            if err and err:match("timeout$") then
              slow_format_filetypes[vim.bo[bufnr].filetype] = true
            end
          end

          return { timeout_ms = 500, lsp_format = "fallback" }, on_format
        end
      '';
    };
  };
}
