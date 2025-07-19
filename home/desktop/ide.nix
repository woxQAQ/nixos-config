{ pkgs, ... }:
let
  claude-code-wrapper = pkgs.callPackage ../../pkg/claude-code-wrapper { };
in
{
  home.packages = with pkgs; [
    zed-editor
    code-cursor
    claude-code-wrapper
  ];
}
