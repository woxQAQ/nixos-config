{ ... }:
{
  imports = [
    ./locale.nix
    ./net.nix
    ./zram.nix
    ./system.nix
    ./misc.nix
    ./user.nix
    ./security.nix
    ./optimization.nix
  ];
}
