{ username, ... }:
{
  # imports = [ inputs.home-manager.nixosModules.home-manager ];
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "input"
      "networkmanager"
      "wheel"
      "audio"
      "pipewire"
      "docker"
    ];
  };
  nix.settings.allowed-users = [ "${username}" ];
}
