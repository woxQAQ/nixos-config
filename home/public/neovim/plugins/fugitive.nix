{ mkKeymap, ... }:
{
  plugins.fugitive = {
    enable = true;
  };
  keymaps = [
    (mkKeymap "n" "<leader>gs" "<cmd>Git<cr>" "Git: show status")
    (mkKeymap "n" "<leader>gw" "<cmd>Gwrite<cr>" "Git: add file")
    (mkKeymap "n" "<leader>gc" "<cmd>Git commit<cr>" "Git: commit changes")
    (mkKeymap "n" "<leader>gpl" "<cmd>Git pull<cr>" "Git: pull changes")
    (mkKeymap "n" "<leader>gpu" "<cmd>Git push<cr>" "Git: push changes")
    (mkKeymap "v" "<leader>gb" "<cmd>Git blame<cr>" "Git: blame selected")
  ];
}
