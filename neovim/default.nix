{ mylib, ... }:
{
  imports = [
    ./autocommands.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
    # ./todo.nix
    ./color.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    performance = {
      combinePlugins = {
        enable = true;
        standalonePlugins = [
          "hmts.nvim"
          "neorg"
          "nvim-treesitter"
          "blink.cmp"
          "oil.nvim"
        ];
      };
      byteCompileLua.enable = true;
    };

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;

    dependencies = {
      chafa.enable = true;
      imagemagick.enable = true;
    };
  };
}
