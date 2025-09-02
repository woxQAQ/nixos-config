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
  home.file.".claude/settings.json".text =
    #json
    ''
      {
        "statusLine": {
          "type":"command",
          "command":"npx -y @owloops/claude-powerline@latest --style=powerline"
        }
      }
    '';
}
