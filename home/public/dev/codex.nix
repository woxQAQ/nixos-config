{ pkgs, ... }:
{
  home.packages = with pkgs; [
    codex
    jq
    curl
  ];
}
