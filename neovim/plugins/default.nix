{
  pkgs,
  mylib,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;
  nvlib = import ../lib;

  # Create scanPlugins function for plugin compatibility
  scanPlugins = nvlib.scanPlugins { inherit mylib; };
  # Plugin arguments to pass to subdirectories
  pluginArgs = {
    inherit
      lib
      pkgs
      scanPlugins
      ;
    inherit (nvlib) icons;
  };

  # Load all plugins with proper arguments
  plugins = scanPlugins ./. pluginArgs;

  # Simplified keymap loading
  pluginsWithKeymap = mylib.getDir ./. "keymaps.nix";
  keymaps = builtins.concatLists (
    map (path: import (./. + "/${path}/keymaps.nix")) pluginsWithKeymap
  );

  # Base plugin configurations
  basePlugins = {
    web-devicons.enable = true;
    nvim-autopairs.enable = true;
    colorizer = {
      enable = true;
      settings.user_default_options.names = false;
      settings.filetypes = {
        css = {
          rgb_fn = true;
        };
      };
    };
    nui.enable = true;
    notify.enable = false;
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
  };

  inherit (lib.attrsets) mergeAttrsList;
in
{
  programs.nixvim = {
    keymaps = keymaps;
    opts.completeopt = [
      "menu"
      "menuone"
      "noselect"
    ];
    # Simplified plugin merging - directly merge all plugin configurations
    plugins = mergeAttrsList (plugins ++ [ basePlugins ]);
  };
}
