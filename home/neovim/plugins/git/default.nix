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
      autoLoad = true;
      settings.current_line_blame = true;
    };
    gitblame.enable = true;
  };
}
