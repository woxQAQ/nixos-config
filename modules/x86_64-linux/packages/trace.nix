{ pkgs, ... }:
{
  programs.wireshark = {
    package = pkgs.wireshark;
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    # syscall monitor
    psmisc
    strace
    iotop-c
    iotools
    ltrace
    ethtool
    usbutils
    pciutils
    parted
    hdparm
    nvme-cli
    dmidecode
    sysstat
    nmon
    smartmontools
  ];
}
