{
  pkgs,
  ...
}:
{
  environment.shells = with pkgs; [
    bashInteractive
    unstable-pkg.nushell
    pwru
  ];
}
