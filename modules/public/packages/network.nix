{ pkgs, ... }:
{
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
    libargon2
    # gui traceroute
    mtr
    # gui ping
    gping
    # dns client
    doggo
    # openbsd-netcat replace
    socat
    # network discovery
    nmap
    # better curl
    xh
    # cmd for URL
    curl
    # download utils
    aria2
    iperf
  ];
}
