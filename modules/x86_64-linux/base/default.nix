{...}: {
  imports = [
    ./locale.nix
    ./net
    ./system.nix
    ./zram.nix
    ./jupyter.nix
    ./git.nix
    ./term
  ];
}
