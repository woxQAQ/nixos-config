{
  conform-nvim = {
    enable = true;
    settings = {
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
