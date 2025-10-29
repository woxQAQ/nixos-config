{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # version controll
    git
    # git with large file support
    git-lfs
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
    # GNU wget, download file via HTTP, HTTPS and FTP
    wget

    # show host info, alternative of neofetch
    fastfetch
    # cmd for URL
    curl
    # download utils
    aria2
    pkg-config
    # log highlighter
    tailspin

    # recursive directory listing
    tree

    # password generator
    pwgen-secure

    killall

    file

    jq
  ];
}
