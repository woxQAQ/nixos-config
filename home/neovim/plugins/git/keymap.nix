{ lib, config, ... }:
{
  programs.nixvim.keymaps =
    let
      normal =
        lib.mapAttrsToList
          (key: action: {
            mode = "n";
            inherit action key;
          })
          {
            "<leader>gb" = ":Gitsigns toggle_current_line_blame<CR>";
            "<leader>gd" = ":Gitsigns diffthis<CR>";
            "<leader>gp" = ":Gitsigns preview_hunk<CR>";
            "<leader>gg" = ":LazyGit";
            "]c" = ":Gitsigns next_hunk<CR>";
            "[c" = ":Gitsigns prev_hunk<CR>";
          };
    in
    config.lib.nixvim.keymaps.mkKeymaps { options.silent = true; } (normal);
}
