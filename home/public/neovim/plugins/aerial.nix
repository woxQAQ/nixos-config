{ mkKeymap, ... }:
{
  plugins.aerial = {
    enable = true;
    settings = {
      layout = {
        # Mixed types are not representable in pure Nix; emit raw Lua.
        # {40, 0.2} means "the lesser of 40 columns or 20% of total".
        max_width.__raw = /* lua */ ''
          { 40, 0.2 }
        '';
        min_width = 20;
      };
    };
  };
  keymaps = [
    (mkKeymap "n" "<leader>ua" "<cmd>AerialToggle!<CR>" "toggle aerial")
    (mkKeymap "n" "{" "<cmd>AerialPrev<CR>" "aerial prev item")
    (mkKeymap "n" "}" "<cmd>AerialNext<CR>" "aerial next item")
  ];
}
