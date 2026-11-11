{
  services.fstrim.enable = true;
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=100"
  ];
}
