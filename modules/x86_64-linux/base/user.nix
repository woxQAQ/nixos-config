{username, ...}: {
  # imports = [ inputs.home-manager.nixosModules.home-manager ];
  users.users.${username} = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "pipewire"
      "docker"
    ];
  };
  nix.settings.allowed-users = ["${username}"];
}
