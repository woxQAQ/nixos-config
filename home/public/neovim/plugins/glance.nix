{ mkKeymap, ... }:
{
  plugins.glance = {
    enable = true;
    lazyLoad.settings.cmd = "Glance";

    settings = {
      height = 25;
      border.enable = true;
    };
  };
  keymaps = [
    (mkKeymap "n" "gd" "<cmd>Glance definitions<CR>" "glance definitions")
    (mkKeymap "n" "gi" "<cmd>Glance implementations<CR>" "glance implementations")
    (mkKeymap "n" "gD" "<cmd>Glance references<CR>" "glance references")
    # (mkKeymap "n" "gt" "<cmd>Glance type_definitions<CR>" "glance type definitions")
  ];
}
