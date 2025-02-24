{
  username,
  ...
}:
{
  # imports = [ inputs.home-manager.nixosModules.home-manager ];
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
}
