{
  imports = [
    ./cmp.nix
    ./blink.nix
  ];
  programs.nixvim = {
    opts.completeopt = [
      "menu"
      "menuone"
      "noselect"
    ];
  };
}
