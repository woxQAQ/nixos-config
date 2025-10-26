{
  pkgs,
  ...
}:
let
  claude-code-wrapper = pkgs.callPackage ../../../pkg/claude-code-wrapper { };
in
{
  home.packages = [
    claude-code-wrapper
  ];
  home.file.".claude/settings.json" = {
    source = ./claude-code.settings.json;
  };
}
