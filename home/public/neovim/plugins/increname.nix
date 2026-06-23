{ mkKeymap, ... }:
{
  plugins.inc-rename = {
    enable = true;
    lazyLoad.settings = {
      event = [
        "DeferredUIEnter"
      ];
    };
    settings = {
      cmd_name = "IncRename";
      show_message = true;
      save_in_cmdline_history = true;
    };
  };
  keymaps = [
    (mkKeymap "n" "grn"
      {
        __raw = ''
          function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end
        '';
      }
      {
        expr = true;
        desc = "Rename Symbol";
      }
    )
  ];
}
