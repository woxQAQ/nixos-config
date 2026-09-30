{ pkgs, llm-agents, ... }:
{
  home.packages = with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    fx
  ];
}
