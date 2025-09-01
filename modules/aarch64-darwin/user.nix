{ username, ... }:
{
  users.users.${username} = {
    home = "/Users/${username}";
    description = username;
  };
  nix.settings.trusted-users = [ username ];
  nix.settings.allowed-users = [ username ];
}
