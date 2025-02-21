{
  programs.nixvim = {
    opts.completeopt = [
      "menu"
      "menuone"
      "noselect"
    ];
    plugins = {
      schemastore = {
        enable = true;
        yaml.enable = true;
        json.enable = false;
      };
    };
  };
}
