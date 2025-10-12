{
  config,
  username,
  stateVersion,
  ...
}:
{
  home = {
    homeDirectory = "/home/${username}";
    file.".npmrc".text = ''
      prefix=${config.home.homeDirectory}/.npm
    '';
    inherit stateVersion;
  };

  programs.home-manager.enable = true;
}
