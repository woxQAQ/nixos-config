{ lib, ... }:
{
  imports = [
    ../../modules/x86_64-linux/system/zram.nix
  ];

  # 4C4G 小内存机器:压缩内存换出比例提高到一半,防止 rebuild 时 OOM 卡死
  zramSwap.memoryPercent = lib.mkForce 50;

  # 限制构建并发,压低 CPU 和内存峰值
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  # NixOS 手册的求值开销较大,服务器不需要
  documentation.nixos.enable = false;
}
