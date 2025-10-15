{ pkgs, ... }:
{
  # environment.variables.EDITOR = "nvim --clean";
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    # morden shell
    nushell

    # version controll
    git
    # git with large file support
    git-lfs

    age

    ### CORE UTILS

    # replace of du
    gdu
    # GNU sed
    gnused
    # sed with diff view
    sad
    # replace of df
    duf
    # replace of du
    du-dust
    # replacement of du interactively
    ncdu
    # replace of find
    fd
    # GNU grep
    gnugrep
    # rg, replace of grep
    ripgrep
    # GNU awk
    gawk
    # GNU which, shows the full path of (shell) commands.
    which
    # GNU Make
    gnumake
    # GNU Compiler Collection
    gcc
    # GNU tar, create tar archives
    gnutar
    # ps alternative
    procs

    # yaml lint and processor
    yq
    wget
    curl
    aria2
    nmap
    # show host info, alternative of neofetch
    fastfetch

    # list open file
    lsof
    # alternative of tldr
    tealdeer
    # program that count code lines
    tokei

    # recursive directory listing
    tree
    rsync
    file

    openssl
    killall

    ### COMPRESSION
    zstd
    zip
    lz4
    p7zip
    unrar
    unar
    unzipNLS
    xz
  ];
}
