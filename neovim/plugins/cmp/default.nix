{
  imports = [
    ./cmp.nix
    ./lspkind.nix
    ./source.nix
  ];
  programs.nixvim = {
    opts.completeopt = [
      "menu"
      "menuone"
      "noselect"
    ];
  };
}
