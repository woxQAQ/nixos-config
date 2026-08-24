{ mkKeymap, ... }:
{
  plugins.snacks = {
    enable = true;
    settings = {
      input = {
        enabled = true;
        win = {
          relative = "cursor";
          backdrop = true;
        };
      };
      picker.enabled = true;
      lazygit = {
        enabled = true;
        configure = true;
      };
      terminal = {
        enabled = true;
        shell = "nu";
      };
      dashboard = {
        preset.header = ''
                            __     _____ __  __ 
          __      _______  _\ \   / /_ _|  \/  |
          \ \ /\ / / _ \ \/ /\ \ / / | || |\/| |
           \ V  V / (_) >  <  \ V /  | || |  | |
            \_/\_/ \___/_/\_\  \_/  |___|_|  |_|
        '';
        sections = [
          { section = "header"; }
          {
            icon = " ";
            title = "Keymaps";
            section = "keys";
          }
          {
            icon = " ";
            title = "Recent Files";
            __unkeyed-1.__raw = "require('snacks').dashboard.sections.recent_files({cwd = true})";
            # gap = 1;
            # padding = 1;
          }
          {
            icon = " ";
            title = "Projects";
            section = "projects";
            # gap = 1;
            # padding = 1;
          }
          # {
          #   pane = 2;
          #   section = "terminal";
          #   cmd = "colorscript -e square";
          #   height = 5;
          #   padding = 2;
          # }
          {
            pane = 2;
            icon = " ";
            desc = "Browse Repo";
            padding = 1;
            key = "b";
            action.__raw = ''
              function()
                Snacks.gitbrowse()
              end'';
          }
          {
            __raw = ''
              function()
                local in_git = Snacks.git.get_root() ~= nil
                local cmds = {
                  -- {
                  --   title = "Notifications",
                  --   cmd = "gh notify -s -a -n5",
                  --   action = function()
                  --     vim.ui.open("https://github.com/notifications")
                  --   end,
                  --   key = "N",
                  --   icon = " ",
                  --   height = 5,
                  --   enabled = true,
                  -- },
                  {
                    title = "Open Issues",
                    cmd = "gh issue list -L 3",
                    key = "i",
                    action = function()
                      vim.fn.jobstart("gh issue list --web", { detach = true })
                    end,
                    icon = " ",
                    height = 7,
                  },
                  {
                    icon = " ",
                    title = "Open PRs",
                    cmd = "gh pr list -L 3",
                    key = "p",
                    action = function()
                      vim.fn.jobstart("gh pr list --web", { detach = true })
                    end,
                    height = 7,
                  },
                  {
                    icon = " ",
                    title = "Git Status",
                    cmd = "git --no-pager diff --stat -B -M -C",
                    height = 10,
                  },
                }
                return vim.tbl_map(function(cmd)
                  return vim.tbl_extend("force", {
                    pane = 2,
                    section = "terminal",
                    enabled = in_git,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                  }, cmd)
                end, cmds)
              end
            '';
          }
        ];
      };
    };
  };
  keymaps = [
    (mkKeymap "n" "<leader>gg" "<cmd>lua Snacks.lazygit()<cr>" "open lazygit")
    (mkKeymap "n" "<C-/>" "<cmd>lua Snacks.terminal.toggle()<CR>" "toggle terminal")
    (mkKeymap "n" "<leader>:" "<cmd>lua Snacks.picker.command_history()<CR>" "Command history")
    (mkKeymap "n" "<leader>fb" "<cmd>lua Snacks.picker.buffers()<CR>" "find buffers")
    (mkKeymap "n" "<leader>fp" "<cmd>lua Snacks.picker.projects()<CR>" "find buffers")
    (mkKeymap "t" "<C-/>" "<cmd>lua Snacks.terminal.toggle()<CR>" "toggle terminal")
  ];
}
