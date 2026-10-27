{ packages }:
{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}:
let
  cfg = config.modules.agents.updateNotifier;
  manifest = pkgs.writeText "llm-agents-installed.json" (
    builtins.toJSON {
      inherit (pkgs.stdenv.hostPlatform) system;
      revision = llm-agents.rev;
      packages = lib.mapAttrs (_: package: {
        inherit (package) version;
      }) packages;
    }
  );
  checker = pkgs.writeShellApplication {
    name = "llm-agents-check-updates";
    runtimeInputs = [
      pkgs.git
      pkgs.nix
      pkgs.terminal-notifier
    ];
    text = ''
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      exec ${pkgs.python3}/bin/python3 ${./check.py} \
        --manifest ${manifest} \
        --expression ${./latest.nix} \
        --state-dir ${lib.escapeShellArg "${config.home.homeDirectory}/Library/Caches/llm-agents-update-notifier"} \
        "$@"
    '';
  };
in
{
  options.modules.agents.updateNotifier.enable = lib.mkOption {
    type = lib.types.bool;
    default = pkgs.stdenv.hostPlatform.isDarwin;
    defaultText = lib.literalExpression "pkgs.stdenv.hostPlatform.isDarwin";
    description = "Check installed llm-agents packages at 09:00 and 15:00 and send macOS notifications.";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.packages = [
      checker
      pkgs.terminal-notifier
    ];
    launchd.agents.llm-agents-update-notifier = {
      enable = true;
      config = {
        ProgramArguments = [ "${checker}/bin/llm-agents-check-updates" ];
        StartCalendarInterval =
          map
            (hour: {
              Hour = hour;
              Minute = 0;
            })
            [
              9
              15
            ];
        ProcessType = "Background";
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/llm-agents-update-notifier.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/llm-agents-update-notifier.log";
      };
    };
  };
}
