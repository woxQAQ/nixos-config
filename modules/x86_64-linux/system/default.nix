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
    ./fhs.nix
    ./ssh.nix
    ./environment.nix
    ./optimization.nix
    ./monitoring.nix
  ];
}
