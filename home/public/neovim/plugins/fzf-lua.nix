{ mkKeymap, ... }:
{
  plugins.fzf-lua = {
    enable = true;
    profile = "telescope";

    lazyLoad.settings.cmd = [
      "FzfLua"
    ];
    settings = {
      oldfiles.cwd_only = true;
      winopts.preview.default = "bat";
    };
  };
  keymaps =
    let
      cmd = sub: "<cmd>FzfLua ${sub}<cr>";
    in
    [
      (mkKeymap "n" "<leader>ff" "${cmd "files"}" "Find files")
      (mkKeymap "n" "<leader>fq" "${cmd "quickfix"}" "Find quickfix")
      (mkKeymap "n" "<leader>fg" "${cmd "live_grep"}" "Find grep")
      (mkKeymap "n" "<leader>fk" "${cmd "keymaps"}" "Find keymaps")
      (mkKeymap "n" "<leader>fT" "${cmd "colorschemes"}" "Find theme")
    ];
}
