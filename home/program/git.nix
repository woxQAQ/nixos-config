{
  config,
  lib,
  ...
}: {
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargers"] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';
  programs.gh = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    includes = [
      {
        path = "${config.home.homeDirectory}/.gnupg/.gitconfig";
      }
    ];
  };
}
