{username, ...}: {
  users.users.${username} = {
    home = "/home/${username}";
    description = username;
  };
  nix.settings.trusted-users = [username];
}
