{
  conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        nix = ["alejandra"];
        rust = ["rustfmt"];
      };
      notify_on_error = false;
    };
  };
}
