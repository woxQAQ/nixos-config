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
  };
}
