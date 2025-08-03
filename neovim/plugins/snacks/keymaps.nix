[
  {
    mode = "n";
    key = "<leader>ff";
    action = ''<cmd>lua Snacks.picker.smart()<cr>'';
    options = {
      desc = "Smart Find Files";
    };
  }
  {
    mode = "n";
    key = "<leader>fq";
    action = ''<cmd>lua Snacks.picker.qflist()<cr>'';
    options = {
      desc = "Find quickfix";
    };
  }
  {
    mode = "n";
    key = "<leader>fg";
    action = "<cmd>lua Snacks.picker.grep()<cr>";
    options = {
      desc = "Live grep";
    };
  }
  {
    mode = "n";
    key = "<leader>f?";
    action = ''<cmd>lua Snacks.picker.grep_buffers()<cr>'';
    options = {
      desc = "Fuzzy find in open buffers";
    };
  }
  {
    mode = "n";
    key = "<leader>fu";
    action = "<cmd>lua Snacks.picker.undo()<cr>";
    options = {
      desc = "Undo History";
    };
  }
  {
    mode = "n";
    key = "<leader>ft";
    action = ''<cmd>lua Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" }})<cr>'';
    options = {
      desc = "Find TODOs";
    };
  }
  {
    mode = "n";
    key = "<leader>fp";
    action = ''<cmd>lua Snacks.picker.projects()<cr>'';
    options = {
      desc = "Find projects";
    };
  }
  {
    mode = "n";
    key = "<leader>fo";
    action = ''<cmd>lua Snacks.picker.recent()<cr>'';
    options = {
      desc = "Find old files";
    };
  }
  {
    mode = "n";
    key = "<leader>fk";
    action = ''<cmd>lua Snacks.picker.keymaps()<cr>'';
    options = {
      desc = "Find keymaps";
    };
  }
  {
    mode = "n";
    key = "<leader>fh";
    action = ''<cmd>lua Snacks.picker.help()<cr>'';
    options = {
      desc = "Find help tags";
    };
  }
  {
    mode = "n";
    key = "<leader>fe";
    action = ''<cmd>lua Snacks.explorer()<cr>'';
    options = {
      desc = "File Explorer";
    };
  }
  {
    mode = "n";
    key = "<leader><space>";
    action = ''<cmd>lua Snacks.picker.buffers()<cr>'';
    options = {
      desc = "Find buffers";
    };
  }
  {
    mode = "n";
    key = "<leader>:";
    action = ''<cmd>lua Snacks.picker.command_history()<cr>'';
    options = {
      desc = "Command History";
    };
  }
  {
    mode = "n";
    key = "<leader>gg";
    action = "<cmd>lua Snacks.lazygit()<CR>";
    options = {
      desc = "Open lazygit";
    };
  }
  {
    mode = "n";
    key = "<leader>fG";
    action = ''<cmd>lua Snacks.picker.git_files()<cr>'';
    options = {
      desc = "Find Git Files";
    };
  }
  {
    mode = "n";
    key = "<leader>gB";
    action = ''<cmd>lua Snacks.picker.git_branches()<cr>'';
    options = {
      desc = "Find git branches";
    };
  }

  {
    mode = "n";
    key = "<leader>gC";
    action = ''<cmd>lua Snacks.picker.git_log()<cr>'';
    options = {
      desc = "Find git commits";
    };
  }
  {
    mode = "n";
    key = "<leader>gs";
    action = ''<cmd>lua Snacks.picker.git_status()<cr>'';
    options = {
      desc = "Find git status";
    };
  }

  {
    mode = "n";
    key = "<leader>gS";
    action = ''<cmd>lua Snacks.picker.git_stash()<cr>'';
    options = {
      desc = "Find git stashes";
    };
  }
  {
    mode = "n";
    key = "<leader>gl";
    action = ''<cmd>lua Snacks.picker.git_log()<cr>'';
    options = {
      desc = "Git Log";
    };
  }
  {
    mode = "n";
    key = "<leader>gL";
    action = ''<cmd>lua Snacks.picker.git_log_line()<cr>'';
    options = {
      desc = "Git Log Line";
    };
  }

  {
    mode = "n";
    key = "<leader>gd";
    action = ''<cmd>lua Snacks.picker.git_diff()<cr>'';
    options = {
      desc = "Git Diff (Hunks)";
    };
  }
  {
    mode = "n";
    key = "<leader>gf";
    action = ''<cmd>lua Snacks.picker.git_log_file()<cr>'';
    options = {
      desc = "Git Log File";
    };
  }
  {
    mode = "n";
    key = "<leader>fd";
    action = ''<cmd>lua Snacks.picker.diagnostics_buffer()<cr>'';
    options = {
      desc = "Find buffer diagnostics";
    };
  }
  {
    mode = "n";
    key = "<leader>fD";
    action = ''<cmd>lua Snacks.picker.diagnostics()<cr>'';
    options = {
      desc = "Find workspace diagnostics";
    };
  }
  {
    mode = "n";
    key = "<leader>fs";
    action = ''<cmd>lua Snacks.picker.lsp_symbols()<cr>'';
    options = {
      desc = "Find lsp document symbols";
    };
  }
  {
    mode = "n";
    key = "gd";
    action = ''<cmd>lua Snacks.picker.lsp_definitions()<cr>'';
    options = {
      desc = "Goto Definition";
    };
  }

  {
    mode = "n";
    key = "gi";
    action = ''<cmd>lua Snacks.picker.lsp_implementations()<cr>'';
    options = {
      desc = "Goto Implementation";
    };
  }
  {
    mode = "n";
    key = "gD";
    action = ''<cmd>lua Snacks.picker.lsp_declarations()<cr>'';
    options = {
      desc = "Goto Declaration";
    };
  }
  {
    mode = "n";
    key = "gr";
    action = ''<cmd>lua Snacks.picker.lsp_references()<cr>'';
    options = {
      desc = "Find references";
    };
  }
  {
    mode = "n";
    key = "gt";
    action = ''<cmd>lua Snacks.picker.lsp_type_definitions()<cr>'';
    options = {
      desc = "Goto Type Definition";
    };
  }

]
