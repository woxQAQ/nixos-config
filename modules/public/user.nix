{username, ...}: {
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "wheel"
      "docker"
    ];
  };
  nix.settings.trusted-users = [username];
}
