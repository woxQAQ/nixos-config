{
  plugins.lint = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    autoInstall = {
      enable = true;
    };
    lintersByFt = rec {
      javascript = [ "biomejs" ];
      json = [ "jq" ];
      nix = [ "deadnix" ];
      typescript = javascript;
    };
  };
}
