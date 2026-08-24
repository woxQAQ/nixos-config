{ config, ... }:
{
  home.file.".npmrc".text = ''
    prefix="${config.home.homeDirectory}/.npm"
    min-release-age=2
  '';
  xdg.configFile."pnpm/config.yaml".text = # yaml
    ''
      minimumReleaseAge: 2880
    '';
}
