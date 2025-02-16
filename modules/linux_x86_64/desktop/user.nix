{
  username,
  inputs,
  nur-ryan4yin,
  host,
  pkgs-unstable,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "pipewire"
    ];
  };
  nix.settings.allowed-users = [ "${username}" ];
  home-manager = {
    backupFileExtension = "home-manager.backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        username
        pkgs-unstable
        host
        nur-ryan4yin
        ;
    };
    users.${username} = {
      imports = [ ../../../home ];
      home.username = "${username}";
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
  };
}
