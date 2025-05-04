{
  telescope = {
    enable = true;

    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fg" = "live_grep";
      "<leader><space>" = "buffers";
      "<leader>fh" = "help_tags";
      "<leader>fd" = "diagnostics";

      "<C-p>" = "git_files";
      "<leader>/" = "oldfiles";
      "<C-f>" = "live_grep";
    };

    extensions = {
      media-files = {
        enable = true;
        dependencies = {
          chafa.enable = true;
          imageMagick.enable = true;
        };
        settings = {
          filetypes = [
            "png"
            "jpg"
            "jepg"
            "webp"
            "gif"
          ];
          find_cmd = "rg";
        };
      };
    };

    settings.defaults = {
      file_ignore_patterns = [
        "^.git/"
        "^.mypy_cache/"
        "^__pycache__/"
        "^output/"
        "^data/"
        "%.ipynb"
      ];
      set_env.COLORTERM = "truecolor";
    };
  };
}
