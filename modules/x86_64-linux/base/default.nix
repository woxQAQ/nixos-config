{ ... }:
{
  imports = [
    ./locale.nix
    ./net
    ./zram.nix
    ./system.nix
    ./misc.nix
    ./user.nix
    ./agenix.nix
  ];
}
