{ config, ... }:
{
  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/darwin/aerospace/aerospace.toml";
}
