{
  pkgs,
  ...
}:
{
  users.defaultUserShell = pkgs.bashInteractive;
}
