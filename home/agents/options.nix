{
  lib,
  ...
}:
{
  options.modules.agents = {
    profile = lib.mkOption {
      type = lib.types.enum [
        "minimal"
        "terminal"
        "full"
      ];
      default = "minimal";
      description = ''
        Package set of the agents module. "minimal" provides the core CLI
        agents (pi, codex, claude-code) plus the toolchain the global
        instructions rely on; "full" adds alternative agents, review tools
        and the desktop app.
      '';
    };
  };
}
