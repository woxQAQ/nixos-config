{ mkKeymap, ... }:
{
  plugins.neo-tree = {
    enable = true;
    lazyLoad.settings.cmd = [ "Neotree" ];
    settings = {
      filesystem = {
        close_if_last_window = true;
        filtered_items = {
          visible = true;
          hide_dotfiles = false;
          hide_hidden = false;
          hide_gitignored = false;
          never_show_by_pattern = [
            ".direnv"
            ".git"
          ];
        };
        follow_current_file = {
          enabled = true;
          leave_dirs_open = true;
        };
      };
      window = {
        width = 40;
        auto_expand_width = false;
      };
    };
  };

  keymaps = [
    (mkKeymap "n" "<leader>e" "<cmd>Neotree action=focus reveal toggle<CR>" "toggle neo tree")
  ];
}
