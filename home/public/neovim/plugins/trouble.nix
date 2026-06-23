{ mkKeymap, ... }:
{
  plugins.trouble = {
    enable = true;
    lazyLoad.settings.cmd = [ "Trouble" ];
    settings = {
      auto_close = true;
    };
  };
  keymaps = [
    (mkKeymap "n" "<leader>xx" "<cmd>Trouble preview_split toggle<CR>" "Diagnostics toggle")
    (mkKeymap "n" "<leader>xX" "<cmd>Trouble preview_split toggle filter.buf=0<CR>"
      "Buffer Diagnostics toggle"
    )
  ];
}
