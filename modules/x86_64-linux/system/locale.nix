{ lib, ... }: {
  i18n.extraLocaleSettings = {
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
  };
  time.timeZone = lib.mkDefault "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
}
