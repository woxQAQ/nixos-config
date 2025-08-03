{
  diffview.enable = true;
  fugitive = {
    enable = true;
  };
  gitsigns = {
    enable = true;
    autoLoad = true;
    settings = {
      current_line_blame = true;
      current_line_blame_opts = {
        delay = 500;
        ignore_blank_lines = true;
        ignore_whitespace = true;
        virt_text = true;
        virt_text_pos = "eol";

      };
      signcolumn = false;
      trouble = true;
    };
  };
  gitblame.enable = true;
}
