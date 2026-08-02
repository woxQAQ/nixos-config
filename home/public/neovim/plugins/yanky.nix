{ mkKeymap, ... }:
let
  keymaps = [
    (mkKeymap [ "n" "x" ] "p" "<Plug>(YankyPutAfter)" "put yanked text after cursor")
    (mkKeymap [ "n" "x" ] "P" "<Plug>(YankyPutBefore)" "put yanked text before cursor")
    (mkKeymap [ "n" "x" ] "y" "<Plug>(YankyYank)" "Yank text")
  ];
  #
  # yankyLazyKeys = map (keymap: {
  #   __unkeyed-1 = keymap.key;
  #
  #   __unkeyed-2 = keymap.action;
  #   mode = keymap.mode or "n";
  #   inherit (keymap.options) desc;
  # }) keymaps;
in
{
  plugins.yanky = {
    enable = true;
    settings = {
      preserve_cursor_position = {
        enabled = false;
      };
      highlight = {
        on_put = true;
        on_yank = false;
        timer = 300;
      };
    };
  };
  inherit keymaps;
}
