{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # eBPF related
    pwru
    bpftrace
    bpftop
    bpftools
    bpfmon
  ];

  programs.bcc.enable = true;
}
