{
  system,
  stateVersion,
  username,
  hostname,
  pkgs,
  ...
}:
{
  networking = {
    hostName = hostname;
    computerName = hostname;
  };
  environment.systemPackages = with pkgs; [
    stats
    daisydisk
  ];
  system = {
    defaults.smb.NetBIOSName = hostname;
    inherit stateVersion;
    primaryUser = username;
  };
  nixpkgs = {
    hostPlatform = system;
  };
}
