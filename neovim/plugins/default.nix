{
  pkgs,
  mylib,
  nixpkgs,
  ...
} @ args: let
  inherit (nixpkgs) lib;
  pluginsWithKeymap = mylib.getDir ./. "keymaps.nix";
  nvlib = import ../lib;

  args = {
    inherit lib mylib pkgs;
  };
  scanPlugins = nvlib.scanPlugins args;
  data = scanPlugins ./. {
    inherit lib pkgs scanPlugins;
  };
  inherit (lib.attrsets) mergeAttrsList;

  keymaps = lib.debug.traceVal (
    builtins.concatLists (
      map (path: import (./. + "/${path}/keymaps.nix"))
      pluginsWithKeymap
    )
  );
in {
  programs.nixvim = {
    opts.completeopt = [
      "menu"
      "menuone"
      "noselect"
    ];
  };
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      leetcode-nvim
    ];
    inherit keymaps;
    #   {
    #   # imports = map (x: x + "/keymaps.nix") pluginsWithKeymap;
    # };
    plugins = mergeAttrsList [
      (mergeAttrsList data)
      {
        web-devicons.enable = true;
        nvim-autopairs.enable = true;
        colorizer = {
          enable = true;
          settings.user_default_options.names = false;
        };
        # nui.enable = true;
        noice.enable = true;
        oil.enable = false;
        notify.enable = true;
        illuminate = {
          enable = true;
          underCursor = true;
          filetypesDenylist = [
            "Outline"
            "TelescopePrompt"
            "reason"
          ];
        };
        trim = {
          enable = true;
          settings = {
            highlight = true;
            ft_blocklist = [
              "checkhealth"
              "floaterm"
              "lspinfo"
              "neo-tree"
              "TelescopePrompt"
            ];
          };
        };
      }
    ];
  };
}
