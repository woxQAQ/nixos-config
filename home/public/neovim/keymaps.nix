{ mkKeymap, ... }:
{
  keymaps = [
    # base
    (mkKeymap "n" "Y" "y$" "Yank to end of line")
    (mkKeymap "n" "j" "v:count == 0 ? 'gj' : 'j'" {
      desc = "Navigate by display line";
      expr = true;
    })
    (mkKeymap "n" "k" "v:count == 0 ? 'gk' : 'k'" {
      desc = "Navigate by display line";
      expr = true;
    })
    (mkKeymap "i" "<c-u>" "<Esc>viwUea" "turn the word under cursor to upper case")
    (mkKeymap "i" "<c-t>" "<Esc>b~lea" "turn the current into case")
    (mkKeymap "i" "<A-;>" "<Esc>miA;<Esc>`ii")
    (mkKeymap "i" "<C-A>" "<Home>")
    (mkKeymap "i" "<C-E>" "<End>")
    (mkKeymap "n" "<leader>q" "<cmd>x<CR>" "Quit file")
    (mkKeymap "n" "<leader>Q" "<cmd>qa<CR>" "Quit file")
    (mkKeymap "x" "$" "g_")
    (mkKeymap "n" "^" "g^")
    (mkKeymap "n" "0" "g0")
    (mkKeymap "n" "<leader>w" "<cmd>update<CR>" "Save and quit")
    (mkKeymap "n" "<leader>qq" ":qa!<CR>" "Quit all without saving")
    (mkKeymap "n" "<Left>" "<C-w>h" "Navigate to left window")
    (mkKeymap "n" "<Right>" "<C-w>l" "Navigate to right window")
    (mkKeymap "n" "<Up>" "<C-w>j" "Navigate to down window")
    (mkKeymap "n" "<Down>" "<C-w>k" "Navigate to upper window")
    (mkKeymap "n" "|" ":vsplit<CR>" "Split window vertically")
    (mkKeymap "n" "-" ":split<CR>" "Split window horizontally")
    (mkKeymap "n" "<leader>sc" "<c-w>c" "Close current window")
    (mkKeymap "n" "<leader>so" "<c-w>o" "Close other windows")
    (mkKeymap "n" "<leader>y" "<cmd>%yank<cr>" "yank entire buffer")
    (mkKeymap "n" "<leader>b[" ":bnext<CR>" "next buffer")
    (mkKeymap "n" "<TAB>" ":bnext<CR>" "next buffer")
    (mkKeymap "n" "<leader>b]" ":bprevious<CR>" "previous buffer")
    (mkKeymap "n" "<S-TAB>" ":bprevious<CR>" "previous buffer")
    (mkKeymap "v" ">" ">gv" "Indent and keep selection")
    (mkKeymap "v" "<TAB>" ">gv" "Indent and keep selection")
    (mkKeymap "v" "<" "<gv" "Unindent and keep selection")
    (mkKeymap "v" "<S-TAB>" "<gv" "Unindent and keep selection")
    (mkKeymap "v" "K" ":m '<-2<CR>gv=gv" "Move selection up")
    (mkKeymap "v" "J" ":m '>+1<CR>gv=gv" "Move selection down")
    (mkKeymap "v" "<BS>" "x" "Backspace delete in visual")
    (mkKeymap "v" "<leader>s" ":sort<CR>" "Sort selection")

  ];
}
