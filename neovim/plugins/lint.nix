{
  lint = {
    enable = true;
    lintersByFt = {
      go = [ "golangcilint" ];
      nix = [
        "deadnix"
        "statix"
      ];
      yaml = [ "yamllint" ];
      sh = [ "shellcheck" ];
      make = [ "checkmake" ];
      markdown = [ "markdownlint" ];
      json = [ "jsonlint" ];
    };
  };
}
