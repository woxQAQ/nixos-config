{ lib, ... }:
{
  # buildGoModule forwards GOPROXY to fixed-output dependency fetchers.
  systemd.services.nix-daemon.environment.GOPROXY = "https://goproxy.cn,direct";

  nix.settings = {
    # Explicit priorities prefer mainland mirrors for cache.nixos.org-signed paths.
    # Our own builds are served separately by Cachix.
    substituters = lib.mkForce [
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=20"
      "https://cache.nixos.org?priority=40"
      "https://woxqaq.cachix.org?priority=50"
    ];
    connect-timeout = 5;
    stalled-download-timeout = 20;
  };
}
