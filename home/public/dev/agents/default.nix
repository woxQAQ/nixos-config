{ config, ... }:
{
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/public/dev/agents/codex/AGENTS.md";
}
