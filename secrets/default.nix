{
  username,
  secrets,
  config,
  pkgs,
  ...
}:
{
  age.identityPaths =
    if pkgs.stdenv.hostPlatform.isLinux then
      [
        "/home/${username}/.ssh/id_ed25519"
      ]
    else
      [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
  age.secrets =
    let
      user_readable = {
        mode = "0500";
        owner = username;
      };
    in
    {
      "private.nu" = {
        file = "${secrets}/private.nu.age";
      }
      // user_readable;
      "github-ssh-key" = {
        file = "${secrets}/github-ssh-key.age";
      }
      // user_readable;
    };
  environment.etc = {
    "agenix/private.nu" = {
      source = config.age.secrets."private.nu".path;
    };
  };
}
