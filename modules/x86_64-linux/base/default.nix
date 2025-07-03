{...}: {
  imports = [
    ./locale.nix
    ./net
    ./zram.nix
    ./jupyter.nix
    ./security.nix
    ./system.nix
    ./misc.nix
    ./user.nix
    ./agenix.nix
    ./secrets.nix
  ];
}
