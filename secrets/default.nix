{
  username,
  secrets,
  config,
  pkgs,
  lib,
  ...
}:
{
  launchd.daemons."activate-agenix".serviceConfig = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };
  age.identityPaths =
    if pkgs.stdenv.hostPlatform.isLinux then
      [
        "/home/${username}/.ssh/id_ed25519"
      ]
    else
      [
        # "/Users/${username}/.ssh/id_ed25519"
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
  system.activationScripts.postActivation.text = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
    ${pkgs.nushell}/bin/nu -c '
    if (ls /etc/agenix/ | length) > 0 {
      sudo chown ${username} /etc/agenix/*
    }
    '
  '';
  environment.etc = {
    "agenix/private.nu" =
      if pkgs.stdenv.hostPlatform.isLinux then
        {
          source = config.age.secrets."private.nu".path;
          mode = "0644";
        }
      else
        {
          source = config.age.secrets."private.nu".path;
        };
  };
}
