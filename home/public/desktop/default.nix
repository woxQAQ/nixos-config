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
  programs.zed-editor = {
    enable = true;
  };
}
