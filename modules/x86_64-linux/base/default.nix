{...}: {
  imports = [
    ./locale.nix
    ./net
    ./zram.nix
    ./jupyter.nix
    ./security.nix
    ./misc.nix
    ./user.nix
  ];
}
