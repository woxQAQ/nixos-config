{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    treefmt
    alejandra

    git
    git-lfs
    fastfetch
    lsof
    tealdeer
    # program that count code lines
    tokei
    # nix formatter
    nixfmt-rfc-style
    age
    tmux

    wget
    curl
    aria2
    nmap

    which
    tree
    rsync
    file

    gnumake
    gcc
    openssl
    killall

    zip
    unar
    gnutar
    unzipNLS
    xz
    p7zip
    zstd

    gnugrep
    gnused
    gawk
  ];
}
