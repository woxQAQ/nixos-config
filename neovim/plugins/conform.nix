{
  conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        nix = [ "alejandra" ];
        rust = [ "rustfmt" ];
        lua = [ "stylua" ];
      };
      formatters.stylua.command = "stylua";
      notify_on_error = false;
    };
  };
}
