{ pkgs, ... }:
let
  v2dat = pkgs.callPackage ../../../pkg/v2dat { };
in
{
  # environment.variables.EDITOR = "nvim --clean";
  environment.systemPackages = with pkgs; [
    # list open file-descriptor
    lsof
    # incremental file transfer
    rsync
    # SSL/TLS utils
    openssl
    # tcp sniffer
    tcpdump
    # dns tools
    dnsutils

    mtr
    v2dat
  ];
}
