{ mkKeymap, ... }:
{
  plugins.aerial = {
    enable = true;
  };
  keymaps = [
    (mkKeymap "n" "<leader>ua" "<cmd>AerialToggle!<CR>" "toggle aerial")
    (mkKeymap "n" "{" "<cmd>AerialPrev<CR>" "aerial prev item")
    (mkKeymap "n" "}" "<cmd>AerialNext<CR>" "aerial next item")
  ];
}
