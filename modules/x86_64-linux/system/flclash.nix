{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.flclash;
in
{
  options.modules.flclash = {
    enable = lib.mkEnableOption "FlClash proxy client";

    user = lib.mkOption {
      type = lib.types.str;
      example = "alice";
      description = ''
        User allowed to drive the helper. The helper filters socket peers by
        uid, so only this user can control the root-running Core.
      '';
    };

    package = lib.mkPackageOption pkgs "flclash" { };
  };

  config = lib.mkIf cfg.enable {
    # The app and the helper service must come from the same package: the
    # helper embeds the Core's sha256 it verifies the managed Core against.
    environment.systemPackages = [ cfg.package ];

    # Since 0.9, FlClash runs its TUN-mode Core through a root helper
    # service listening on /run/flclash/helper.sock. Upstream's installer
    # writes /etc/systemd/system itself via pkexec/sudo, which cannot work
    # on NixOS, so the unit is declared here instead, mirroring
    # services/helper/src/service/linux.rs.
    systemd.services.flclash-helper = {
      description = "FlClash Helper starts the FlClash Core with the privileges TUN mode needs";
      after = [
        "network-online.target"
        "nftables.service"
        "iptables.service"
      ];
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 60;
      startLimitBurst = 5;
      serviceConfig = {
        Type = "simple";
        # The helper authorizes socket peers against the owner ids in its
        # environment; resolve them at start so the unit does not bake in
        # an auto-allocated uid.
        ExecStart = toString (
          pkgs.writeShellScript "flclash-helper-start" ''
            export FLCLASH_HELPER_OWNER_UID="$(id -u ${lib.escapeShellArg cfg.user})"
            export FLCLASH_HELPER_OWNER_GID="$(id -g ${lib.escapeShellArg cfg.user})"
            exec ${cfg.package}/bin/FlClashHelperService
          ''
        );
        Group = config.users.users.${cfg.user}.group;
        RuntimeDirectory = "flclash";
        RuntimeDirectoryMode = "0755";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
