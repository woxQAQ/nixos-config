{
  system,
  stateVersion,
  username,
  hostname,
  ...
}:
{
  networking = {
    hostName = hostname;
    computerName = hostname;
  };
  system.defaults.smb.NetBIOSName = hostname;
  system.stateVersion = stateVersion;
  system.primaryUser = username;
  nixpkgs = {
    hostPlatform = system;
  };
}
