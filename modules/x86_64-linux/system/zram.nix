{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    swapDevices = 1;
    memoryPercent = 30;
  };
}
