{
  config,
  pkgs,
  lib,
  ...
}: let
  nvlib = import ./lib;
  keys_ = nvlib.keys {inherit lib;};
  normalFunc = keys_.normal;
  visualFunc = keys_.visual;
  actionWithDesc = keys_.actionWithDesc;
  normalSet =
    normalFunc {
      "<Space>" = "<NOP>";

      # Esc to clear search results
      "<esc>" = ":noh<CR>";

      # fix Y behaviour
      Y = "y$";

      # back and fourth between the two most recent files
      "<C-c>" = ":b#<CR>";

      # close by Ctrl+x
      "<C-x>" = ":close<CR>";

      # save by Space+s or Ctrl+s
      "<leader>s" = actionWithDesc ":w<CR>" "save file";
      "<C-s>" = ":w<CR>";

      # navigate to left/right window
      "<leader>h" = actionWithDesc "<C-w>h" "navigate to left window";
      "<leader>l" = actionWithDesc "<C-w>l" "navigate to right window";
      "<leader>j" = actionWithDesc "<C-w>j" "navigate to down window";
      "<leader>k" = actionWithDesc "<C-w>k" "navigate to upper window";

      "<leader>sl" = actionWithDesc "<c-w>v" "split window vertical";
      "<leader>sj" = actionWithDesc "<c-w>h" "split window horizontal";

      # Press 'H', 'L' to jump to start/end of a line (first/last character)
      L = actionWithDesc "$" "jump to start of line";
      H = actionWithDesc "^" "jump to end of line";

      # move current line up/down
      # M = Alt key
      "<M-k>" = ":move-2<CR>";
      "<M-j>" = ":move+<CR>";

      # "<leader>rp" = ":!remi push<CR>";
    }
    // lib.optionals pkgs.stdenv.hostPlatform.isLinux {
      # resize with arrows
      "<C-Up>" = actionWithDesc ":resize +2<CR>" "resize larger horizontal";
      "<C-Down>" = actionWithDesc ":resize -2<CR>" "resize smaller horizontal";
      "<C-Left>" = ":vertical resize +2<CR>";
      "<C-Right>" = ":vertical resize -2<CR>";
    };
  visualSet = visualFunc {
    ">" = ">gv";
    "<" = "<gv";
    # "<TAB>" = ">gv";
    # "<S-TAB>" = "<gv";

    # move selected line / block of text in visual mode
    "K" = ":m '<-2<CR>gv=gv";
    "J" = ":m '>+1<CR>gv=gv";

    # sort
    "<leader>s" = ":sort<CR>";
  };
in {
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    keymaps = config.lib.nixvim.keymaps.mkKeymaps {
      options.silent = true;
    } (normalSet ++ visualSet);
  };
}
