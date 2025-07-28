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
    cloc
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
    libseccomp
    killall

    zip
    unar
    gnutar
    unzipNLS
    xz
    p7zip
    zstd
    ripgrep

    gnugrep
    gnused
    gawk
    jq
  ];
}
