{
  programs.nixvim.plugins = {
    fidget = {
      enable = true;
      settings = {
        logger = {
          level = "warn"; # "off", "error", "warn", "info", "debug", "trace"
          float_precision = 1.0e-2; # Limit the number of decimals displayed for floats
        };
      };
    };
  };
}
