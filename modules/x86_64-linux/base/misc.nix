{
  pkgs,
  unstable-pkg,
  ...
}:
{
  environment.shells = with pkgs; [
    bashInteractive
    unstable-pkg.nushell
  ];
  users.defaultUserShell = pkgs.bashInteractive;
}
