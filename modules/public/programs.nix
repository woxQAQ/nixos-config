{
  pkgs,
  lib,
  ...
}:
{
  environment.variables.EDITOR = lib.mkOverride 900 "vim";
  environment.systemPackages = with pkgs; [
    nushell
    vim

    age
    yq
    nmap
    lsof
    tealdeer
    tokei
    rsync
    openssl
  ];
}
