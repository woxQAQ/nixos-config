{
  lsp.servers.nixd = {
    enable = true;
    settings.settings = {
      nixpkgs.expr = "import <nixpkgs> { }";
      formatting = {
        command = [ "nixfmt" ];
      };
    };
  };
}
