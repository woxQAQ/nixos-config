{
  lib,
  pkgs,
  username,
  config,
  secrets,
  ...
}:
{
  launchd.daemons."activate-agenix".serviceConfig = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };
  age.identityPaths = [
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
    "agenix/private.nu" = {
      source = config.age.secrets."private.nu".path;
    };
  };

}
