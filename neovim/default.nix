{ mylib, lib, ... }:
{
  imports = [
    ./plugins
    ./autocommands.nix
    ./color.nix
    ./keymaps.nix
    ./options.nix
    ./todo.nix
    ./lsp.nix
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
      byteCompileLua = {
        enable = true;
        configs = true;
        luaLib = true;
        nvimRuntime = true;
        plugins = true;
      };
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
