{
  pkgs,
  ...
}:
let
  claude-code-wrapper = pkgs.callPackage ../../../pkg/claude-code-wrapper { };
in
{
  home.packages = with pkgs; [
    code-cursor
    zed-editor
    claude-code-wrapper
  ];
}
