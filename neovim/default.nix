{
  mylib,
  ...
}: {
  imports = [
    ./autocommands.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
    ./todo.nix
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
        ];
      };
      byteCompileLua.enable = true;
    };

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;
  };
}
