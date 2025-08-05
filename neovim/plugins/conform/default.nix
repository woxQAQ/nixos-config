{
  conform-nvim = {
    enable = true;
    settings = {
      default_format_opts.lsp_format = "prefer";
      formatters_by_ft = {
        nix = [ "nixfmt" ];
        rust = [ "rustfmt" ];
        lua = [ "stylua" ];
        python = [
          "isort"
          "ruff"
        ];
      };
      formatters.stylua.command = "stylua";
      notify_on_error = false;
    };
  };
}
