{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # eBPF related
    pwru
    bpftrace
    bpftop
    bpfmon

    # syscall monitor
    strace
    ltrace
    ethtool
    usbutils
    pciutils
    hdparm
    dmidecode
    systemctl-tui
    nmon
  ];
}
