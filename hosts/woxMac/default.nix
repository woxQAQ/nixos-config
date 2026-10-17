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
      stats
      ghidra
      bitwarden-desktop
      cc-switch
      mole-cleaner
      obsidian
      removemacai
    ];
  };
}
