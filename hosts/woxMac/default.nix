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
  system = {
    defaults.smb.NetBIOSName = hostname;
    inherit stateVersion;
    primaryUser = username;
  };
  nixpkgs = {
    hostPlatform = system;
  };
  environment = {
    systemPackages = with pkgs; [
      # aerospace
      bitwarden-desktop
      cc-switch
      koodo-reader
      mole-cleaner
      obsidian
    ];
  };
}
