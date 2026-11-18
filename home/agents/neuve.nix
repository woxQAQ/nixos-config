{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.agents.neuve;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  setupRepository =
    path: repository:
    let
      setup = lib.escapeShellArgs [
        "${cfg.package}/bin/neuve"
        "setup"
        "--repo"
        path
        "--route"
        cfg.route
        "--cli-binary"
        "${cfg.package}/bin/neuve"
        "--graph-binary"
        "${cfg.package}/lib/neuve/entire-graph"
        "--no-skills"
      ];
      hooks = lib.escapeShellArgs (
        [
          "${cfg.package}/bin/neuve"
          "setup"
          "hooks"
          "--repo"
          path
          "--command"
          "${config.home.profileDirectory}/bin/neuve"
          "--agents"
          (
            if repository.hooks.agents == [ ] then
              "none"
            else
              lib.concatStringsSep "," repository.hooks.agents
          )
        ]
        ++ lib.optional (!repository.stack.enable) "--no-stack"
        ++ lib.optional repository.hooks.sessionTrailer "--session-trailer"
      );
    in
    ''
      run ${setup} < /dev/null
      ${lib.optionalString repository.hooks.enable ''
        run ${hooks} < /dev/null
      ''}
    '';
in
{
  options.modules.agents.neuve = {
    enable = mkEnableOption "Neuve code review and repository setup";

    package = lib.mkPackageOption pkgs "neuve" { };

    skills.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Distribute the selected Neuve package's skill through agent-skills.";
    };

    route = mkOption {
      type = types.enum [
        "anthropic"
        "openai"
        "claude"
      ];
      default = "anthropic";
      description = ''
        Review sign-in route passed to setup for every configured repository.
        Credentials remain managed by Neuve or the selected provider.
      '';
    };

    repositories = mkOption {
      default = { };
      description = ''
        Existing Git repositories to set up at activation, keyed by absolute path.
        Setup refreshes CLI and Graph paths on each activation. Removing an entry
        leaves its existing setup and captured records in place.
      '';
      type = types.attrsOf (
        types.submodule {
          options = {
            hooks = {
              enable = mkEnableOption "Git and agent session capture hooks";
              agents = mkOption {
                type = types.listOf (
                  types.enum [
                    "claude-code"
                    "codex"
                  ]
                );
                default = [
                  "claude-code"
                  "codex"
                ];
                description = ''
                  User-level agent hooks installed by setup hooks. An empty list
                  installs only Git hooks. Existing user configuration is merged
                  and backed up by Neuve.
                '';
              };
              sessionTrailer = mkEnableOption "Neuve-Session commit trailers";
            };
            stack.enable = mkEnableOption "dependency source fetching during hook setup";
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    assertions = lib.mapAttrsToList (path: _repository: {
      assertion = lib.hasPrefix "/" path;
      message = "modules.agents.neuve.repositories requires an absolute path: ${path}";
    }) cfg.repositories;

    home.packages = [ cfg.package ];

    home.activation.neuveSetup =
      lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ]
        ''
          export PATH="${lib.makeBinPath [ pkgs.git ]}:$PATH"
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList setupRepository cfg.repositories
          )}
        '';
  };
}
