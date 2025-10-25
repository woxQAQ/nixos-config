{
  username,
  config,
  pkgs,
  lib,
  ...
}:
{
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargers" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';
  programs = {
    gh.enable = true;
    lazygit.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {

      user = {
        name = if pkgs.stdenv.isLinux then username else "woxQAQ";
        email = "woxqaq@gmail.com";
      };
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      trim.bases = "develop,master,main";
      pull.rebase = true;
      log.date = "iso";
      aliases = {
        cm = "commit -m"; # commit via `git cm <message>`
        ca = "commit -am"; # commit all changes via `git ca <message>`
        amend = "commit --amend -m";
      };
    };
    includes = [
      {
        path = "${config.home.homeDirectory}/.gnupg/.gitconfig";
      }
    ];

  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      diff-so-fancy = true;
      line-numbers = true;
      true-color = "always";
    };
  };
}
