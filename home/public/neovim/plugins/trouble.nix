{ mkKeymap, ... }:
{
  plugins.trouble = {
    enable = true;
    lazyLoad.settings.cmd = [ "Trouble" ];
    settings = {
      auto_close = true;
      modes = {
        preview_split = {
          # NOTE: can automatically open when diagnostics exist
          # auto_open = true;
          mode = "diagnostics";
          preview = {
            type = "split";
            relative = "win";
            position = "right";
            size = 0.5;
          };
        };
      };
    };
  };
  keymaps = [
    (mkKeymap "n" "<leader>xx" "<cmd>Trouble preview_split toggle<CR>" "Diagnostics toggle")
    (mkKeymap "n" "<leader>xX" "<cmd>Trouble preview_split toggle filter.buf=0<CR>"
      "Buffer Diagnostics toggle"
    )
  ];
}
