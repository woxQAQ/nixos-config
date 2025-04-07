{
  system,
  stateVersion,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    computerName = hostname;
  };
  system.defaults.smb.NetBIOSName = hostname;
  system.stateVersion = stateVersion;
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
    };
  };
}
