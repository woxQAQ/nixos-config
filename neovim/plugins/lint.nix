{
  lint = {
    enable = true;
    lintersByFt = {
      go = ["golangcilint"];
      nix = [
        "nix"
        "statix"
      ];
    };
  };
}
