{pkgs,unstable-pkg,...}:{
  environment.shells = with pkgs; [
    bashInteractive
    unstable-pkg.nushell
  ];
  environment.systemPackages = with pkgs; [
    ntfs3g
  ];
  users.defaultUserShell = pkgs.bashInteractive;
}
