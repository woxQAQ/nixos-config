[
  {
    mode = "n";
    key = "<leader>gb";
    action = ":Gitsigns toggle_current_line_blame<CR>";
    options.silent = true;
  }
  {
    mode = "n";
    key = "<leader>gd";
    # action = ":Gitsigns diffthis<CR>";
    action.__raw = ''
      function()
        vim.g.diffview_enabled = not vim.g.diffview_enabled
        if vim.g.diffview_enabled then
          vim.cmd('DiffviewClose')
        else
          vim.cmd('DiffviewOpen')
        end
      end
    '';
    options.silent = true;
  }
  {
    mode = [
      "n"
      "v"
    ];
    key = "<leader>ghs";
    action = "<cmd>Gitsigns stage_hunk<CR>";
    options = {
      desc = "Stage hunk";
    };
  }
  {
    mode = "n";
    key = "<leader>ghu";
    action = "<cmd>Gitsigns undo_stage_hunk<CR>";
    options = {
      desc = "Undo stage hunk";
    };
  }
  {
    mode = [
      "n"
      "v"
    ];
    key = "<leader>ghr";
    action = "<cmd>Gitsigns reset_hunk<CR>";
    options = {
      desc = "Reset hunk";
    };
  }
  {
    mode = "n";
    key = "<leader>ghP";
    action = ":Gitsigns preview_hunk<CR>";
    options.silent = true;
  }
  {
    mode = "n";
    key = "<leader>ghp";
    action = "<cmd>Gitsigns preview_hunk_inline<CR>";
    options = {
      desc = "Preview hunk inline";
    };
  }
  {
    mode = "n";
    key = "<leader>gS";
    action = "<cmd>Gitsigns stage_buffer<CR>";
    options = {
      desc = "Stage buffer";
    };
  }
  {
    mode = "n";
    key = "]h";
    action = ":Gitsigns next_hunk<CR>";
    options.silent = true;
  }
  {
    mode = "n";
    key = "[h";
    action = ":Gitsigns prev_hunk<CR>";
    options.silent = true;
  }
]
