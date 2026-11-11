{
  boot = {
    consoleLogLevel = 3;
    loader = {
      grub.enable = false;
      systemd-boot = {
        enable = true;
        # Limit kernel/initrd copies on the shared Windows ESP.
        configurationLimit = 10;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernelParams = [
      "quiet"
      "loglevel=3"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      "rd.systemd.show_status=auto"
    ];
  };
}
