{
  username,
  secrets,
  config,
  ...
}:
{

  age.identityPaths = [
    "/home/${username}/.ssh/id_ed25519"
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
      mode = "0644";
    };

  };
}
