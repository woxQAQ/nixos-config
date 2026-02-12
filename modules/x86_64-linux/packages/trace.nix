{ pkgs, ... }:
{
  programs.wireshark = {
    package = pkgs.wireshark;
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    # eBPF related
    pwru
    bpftrace
    bpftop
    bpftools
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
