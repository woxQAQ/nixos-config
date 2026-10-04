{ lib, ... }:
{
  imports = [
    ../../modules/x86_64-linux/system/zram.nix
  ];

  # 4C4G 小内存机器:zram 设备给到与内存等大（zstd 实际占用约为压缩后的一半），
  # 防止 swap 耗尽导致 kswapd 抖振与 rebuild OOM 卡死
  zramSwap.memoryPercent = lib.mkForce 100;

  # 限制构建并发,压低 CPU 和内存峰值
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  # NixOS 手册的求值开销较大,服务器不需要
  documentation.nixos.enable = false;
}
