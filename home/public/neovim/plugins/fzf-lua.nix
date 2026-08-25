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
      winopts = {
        preview.default = "bat";
        row = 0.5;
        height = 0.7;
      };
    };
  };
  keymaps =
    let
      cmd = sub: "<cmd>FzfLua ${sub}<cr>";
    in
    [
      (mkKeymap "n" "<leader>ff" "${cmd "files"}" "Find files")
      (mkKeymap "n" "<leader>fq" "${cmd "quickfix"}" "Find quickfix")
      (mkKeymap "n" "<leader>fg" "${cmd "live_grep_native"}" "Find grep")
      (mkKeymap "n" "<leader>ft" "${cmd "lsp_document_symbols"}" "Find lsp symbols")
      (mkKeymap "n" "<leader>fb" "${cmd "buffers"}" "fuzzy search opened files")
      (mkKeymap "n" "<leader>fb" "${cmd "oldfiles"}" "fuzzy search opened files history")
      (mkKeymap "n" "<leader>fk" "${cmd "keymaps"}" "Find keymaps")
      (mkKeymap "n" "<leader>fT" "${cmd "colorschemes"}" "Find theme")
    ];
}
