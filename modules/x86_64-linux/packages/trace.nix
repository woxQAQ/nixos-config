{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pwru
    bpftrace
    # syscall monitor
    strace
  ];
}
