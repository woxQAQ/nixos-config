{
  plugins.navic = {
    enable = true;

    lazyLoad.settings.event = [
      "BufReadPost"
      "BufNewFile"
    ];

    settings = {
      lsp = {
        auto_attach = true;
      };
      separator = "  ";
      highlight = true;
      depthLimit = 5;
    };
  };
}
