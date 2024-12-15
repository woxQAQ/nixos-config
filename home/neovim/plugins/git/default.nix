{
  imports = [ ./keymap.nix ];
  programs.nixvim.plugins = {
    lazygit = {
      enable = true;
    };
    fugitive = {
      enable = true;
    };
    gitsigns = {
      enable = true;
      settings.signs = {
        add.text = "+";
        change.text = "~";
      };
    };
  };
}
