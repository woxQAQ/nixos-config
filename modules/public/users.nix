{
  username,
  lib,
  ...
}:
lib.mkMerge [
  {
    users.users.${username}.description = username;
  }
]
