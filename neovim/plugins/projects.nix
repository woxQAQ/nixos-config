{
  config,
  lib,
  ...
}: {
  programs.nixvim.plugins.project-nvim = {
    enable = true;
    enableTelescope = true;
  };
  programs.nixvim.keymaps = let
    normal =
      lib.mapAttrsToList
      (key: action: {
        mode = "n";
        inherit action key;
      })
      {
        "<leader>p" = ":Telescope projects<CR>";
      };
  in
    config.lib.nixvim.keymaps.mkKeymaps {options.silent = true;} normal;
}
