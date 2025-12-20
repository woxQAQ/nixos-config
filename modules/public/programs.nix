{
  pkgs,
  lib,
  ...
}:
{
  environment.variables.EDITOR = lib.mkForce "nvim --clean";
  environment.systemPackages = with pkgs; [
    # morden shell
    nushell

    age
    # yaml lint and processor
    yq
    nmap

    # list open file
    lsof
    # alternative of tldr
    tealdeer
    # program that count code lines
    tokei

    rsync

    openssl
  ];
}
