{...}: {
  imports = [
    ./locale.nix
    ./net
    ./system.nix
    ./zram.nix
    ./jupyter.nix
    ./security.nix
    ./misc.nix
    ./user.nix
    ./git.nix
  ];
}
