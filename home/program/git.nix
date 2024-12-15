{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargers" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "woxQAQ";
    userEmail = "woxqaq@gmail.com";

    includes = [
      {
        path = "${config.home.homeDirectory}/.gnupg/.gitconfig";
      }
    ];
  };
}
