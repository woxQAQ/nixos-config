{
  pkgs,
  ...
}:
let
  claude-code-wrapper = pkgs.callPackage ../../../pkg/claude-code-wrapper { };
in
{
  home.packages = with pkgs; [
    claude-code-wrapper
  ];
  home.file.".claude/settings.json" =
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
