{
  claude-code-pkg,
  ...
}:
let
  claude-code-wrapper = claude-code-pkg.callPackage ../../../pkg/claude-code-wrapper { };
in
{
  home.packages = [
    claude-code-wrapper
  ];
  home.file.".claude/settings.json" = {
    source = ./claude-code.settings.json;
  };
}
