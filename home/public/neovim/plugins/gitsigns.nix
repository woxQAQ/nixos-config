{ mkKeymap, ... }:
{
  plugins.gitsigns = {
    enable = true;
    lazyLoad.settings.event = [
      "BufReadPost"
      "BufNewFile"
    ];

    settings = {
      current_line_blame = true;

      current_line_blame_opts = {
        delay = 1000;

        ignore_blank_lines = true;
        ignore_whitespace = true;
        virt_text = true;
        virt_text_pos = "eol";
      };
      word_diff = false;
      signcolumn = true;
      update_debounce = 200;
    };
  };
  keymaps = [
    (mkKeymap "n" "]c" {
      __raw = ''
        function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function() require('gitsigns').nav_hunk('next')end)
          return '<Ignore>'
        end
      '';
    } "next hunk")
  ];
}
