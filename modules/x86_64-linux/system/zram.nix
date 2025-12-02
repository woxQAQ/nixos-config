{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    swapDevices = 1;
    memoryPercent = 30;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
