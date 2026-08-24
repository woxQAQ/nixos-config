{
  config,
  mylib,
  dotfilesDir,
  ...
}:
let
  mkMutable = mylib.mkMutable dotfilesDir config;
in
{
  imports = [ ./ag-skills.nix ];

  home.file = {
    ".codex/AGENTS.md".source = mkMutable ./codex/AGENTS.md;
    ".kimi-code/AGENTS.md".source = mkMutable ./codex/AGENTS.md;
    "pi/agent/AGENTS.md".source = mkMutable ./pi/AGENTS.md;
  };
}
