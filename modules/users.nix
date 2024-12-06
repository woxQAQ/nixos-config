{
  pkg,
  lib,
  username,
  ...
}:
{
  users.user.${username} = {
    isNormalUser = true;
    description = username;
  };
  nix.settings.trusted-users = [ username ];
}
