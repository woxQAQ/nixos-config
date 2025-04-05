{username, ...}: {
  users.users.${username} = {
    extraGroups = [
      "wheel"
      "docker"
    ];
  };
}
