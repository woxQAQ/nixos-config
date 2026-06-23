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
