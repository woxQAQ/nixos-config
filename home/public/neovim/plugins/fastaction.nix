{ mkKeymap, ... }:
{
  plugins.fastaction = {
    enable = true;
    lazyLoad.settings.lazy = true;
  };
  keymaps = [
    (mkKeymap "n" "<leader>lc" "<cmd>lua require('fastaction').code_action()<cr>" "code action")
    (mkKeymap "v" "<leader>lc" "<cmd>lua require('fastaction').range_code_action()<cr>" "code action")
  ];
}
