{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    treefmt
    alejandra
    nil

    git
    git-lfs
    fastfetch
    lsof
    tldr
    cloc
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
    killall

    zip
    unar
    gnutar
    unzipNLS
    xz
    p7zip
    zstd
    ripgrep
    gtop

    gnugrep
    gnused
    gawk
    jq
  ];
}
