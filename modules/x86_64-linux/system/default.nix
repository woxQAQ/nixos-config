{ ... }:
{
  imports = [
    ./locale.nix
    ./net.nix
    ./zram.nix
    ./system.nix
    ./misc.nix
    ./fhs.nix
    ./ssh.nix
    ./environment.nix
    ./optimization.nix
    ./flclash.nix
    ./users.nix
    ./qmk.nix
  ];
}
