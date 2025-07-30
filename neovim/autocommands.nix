{
  programs.nixvim = {
    autoGroups = {
      highlight_yank = { };
      vim_enter = { };
      indentscope = { };
      restore_cursor = { };
    };
    autoCmd = [
      {
        group = "highlight_yank";
        event = [ "TextYankPost" ];
        pattern = "*";
        callback = {
          __raw = ''
            function()
              vim.highlight.on_yank()
            end
          '';
        };
      }
      {
        group = "indentscope";
        event = [ "FileType" ];
        pattern = [
          "help"
          "Startup"
          "startup"
          "neo-tree"
          "Trouble"
          "trouble"
          "notify"
        ];
        callback = {
          __raw = ''
            function()
              vim.b.miniindentscope_disable = true
            end
          '';
        };
      }
      # Open help in a vertical split
      {
        event = "FileType";
        pattern = "help";
        command = "wincmd L";
      }

      # Enable spellcheck for some filetypes
      {
        event = "FileType";
        pattern = [
          "tex" # inria
          "latex" # inria
          "markdown"
        ];
        command = "setlocal spell spelllang=en";
      }
      {
        event = "FileType";
        pattern = "helm";
        command = "LspRestart";
      }
      {
        group = "restore_cursor";
        event = [ "BufReadPost" ];
        pattern = "*";
        callback = {
          __raw = ''
            function()
              if
                vim.fn.line "'\"" > 1
                and vim.fn.line "'\"" <= vim.fn.line "$"
                and vim.bo.filetype ~= "commit"
                and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
              then
                vim.cmd "normal! g`\""
              end
            end
          '';
        };
      }
    ];
  };
}
