{
  config,
  pkgs,
  lib,
  ...
}:
let
  nvlib = import ./lib;
  keys = nvlib.keys { inherit lib; };

  flattenKeyMaps =
    keymaps:
    let
      flatten = x: if builtins.isList x then lib.concatMap flatten x else [ x ];
    in
    flatten keymaps;

  # Enhanced keymap helpers
  inherit (keys)
    normal
    visual
    nv
    ni
    nvi
    category
    ;
  # Core keymaps grouped by functionality
  coreKeymaps = category "core" [
    (normal "<Space>" "<NOP>" "Disable space bar" { silent = true; })
    (normal "<esc>" ":noh<CR>" "Clear search highlights" { silent = true; })
    (normal "Y" "y$" "Yank to end of line" { silent = true; })
    (normal "<C-c>" ":b#<CR>" "Switch to previous buffer" { })
    (normal "<C-x>" ":close<CR>" "Close current window" {
      silent = true;
      nowait = true;
    })
    (nvi "<C-s>" ":w<CR>" "Save file" { silent = true; })
  ];

  # File operations
  fileKeymaps = category "files" [
    (normal "<leader>s" ":w<CR>" "Save file" { silent = true; })
    (normal "<leader>q" ":q<CR>" "Quit file" { silent = true; })
    (normal "<leader>wq" ":wq<CR>" "Save and quit" { silent = true; })
    (normal "<leader>qq" ":qa!<CR>" "Quit all without saving" { silent = true; })
  ];

  # Window navigation
  windowKeymaps = category "windows" [
    (normal "<leader>h" "<C-w>h" "Navigate to left window" { silent = true; })
    (normal "<leader>l" "<C-w>l" "Navigate to right window" { silent = true; })
    (normal "<leader>j" "<C-w>j" "Navigate to down window" { silent = true; })
    (normal "<leader>k" "<C-w>k" "Navigate to upper window" { silent = true; })
    (normal "<leader>sl" "<c-w>v" "Split window vertically" { silent = true; })
    (normal "<leader>sj" "<c-w>s" "Split window horizontally" { silent = true; })
    (normal "<leader>sc" "<c-w>c" "Close current window" { silent = true; })
    (normal "<leader>so" "<c-w>o" "Close other windows" { silent = true; })
  ];

  # Line navigation
  lineKeymaps = category "lines" [
    (normal "L" "$" "Jump to end of line" { silent = true; })
    (normal "H" "^" "Jump to start of line" { silent = true; })
    (normal "<M-k>" ":move-2<CR>" "Move line up" { silent = true; })
    (normal "<M-j>" ":move+<CR>" "Move line down" { silent = true; })
  ];

  # Multi-mode keymaps examples
  multiModeKeymaps = category "multi-mode" [
    (nv "j" "gj" "Navigate by display line" { silent = true; })
    (nv "k" "gk" "Navigate by display line" { silent = true; })
    (ni "<C-h>" "<Left>" "Move left in insert mode" { silent = true; })
    (ni "<C-j>" "<Down>" "Move down in insert mode" { silent = true; })
    (ni "<C-k>" "<Up>" "Move up in insert mode" { silent = true; })
    (ni "<C-l>" "<Right>" "Move right in insert mode" { silent = true; })
  ];

  # Linux-specific keymaps
  linuxKeymaps = category "linux" [
    (normal "<C-Up>" ":resize +2<CR>" "Resize window up" { silent = true; })
    (normal "<C-Down>" ":resize -2<CR>" "Resize window down" { silent = true; })
    (normal "<C-Left>" ":vertical resize +2<CR>" "Resize window left" { silent = true; })
    (normal "<C-Right>" ":vertical resize -2<CR>" "Resize window right" { silent = true; })
  ];

  # Visual mode keymaps
  visualKeymaps = category "visual" [
    (visual ">" ">gv" "Indent and keep selection" { silent = true; })
    (visual "<" "<gv" "Unindent and keep selection" { silent = true; })
    (visual "K" ":m '<-2<CR>gv=gv" "Move selection up" { silent = true; })
    (visual "J" ":m '>+1<CR>gv=gv" "Move selection down" { silent = true; })
    (visual "<leader>s" ":sort<CR>" "Sort selection" { silent = true; })
  ];

  # Collect all keymaps without global silent option
  allKeymaps = flattenKeyMaps [
    coreKeymaps.keymaps
    fileKeymaps.keymaps
    windowKeymaps.keymaps
    lineKeymaps.keymaps
    multiModeKeymaps.keymaps
    (lib.optionals pkgs.stdenv.hostPlatform.isLinux linuxKeymaps.keymaps)
    visualKeymaps.keymaps
  ];
in
{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    keymaps = config.lib.nixvim.keymaps.mkKeymaps { } allKeymaps;
  };
}
