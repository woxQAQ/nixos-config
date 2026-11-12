{ lib, ... }:
{
  imports = [
    ../../modules/x86_64-linux/system/zram.nix
  ];

  zramSwap.memoryPercent = lib.mkForce 100;

  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  documentation.nixos.enable = false;
}
