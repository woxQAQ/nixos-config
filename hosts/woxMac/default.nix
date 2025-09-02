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
  system = {
    defaults.smb.NetBIOSName = hostname;
    inherit stateVersion;
    primaryUser = username;
  };
  nixpkgs = {
    hostPlatform = system;
  };
}
