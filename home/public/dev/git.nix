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
  programs.gh = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = if pkgs.stdenv.isLinux then username else "woxQAQ";
    userEmail = "woxqaq@gmail.com";
    includes = [
      {
        path = "${config.home.homeDirectory}/.gnupg/.gitconfig";
      }
    ];
    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
    delta = {
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
      };
    };
    aliases = {
      cm = "commit -m"; # commit via `git cm <message>`
      ca = "commit -am"; # commit all changes via `git ca <message>`
      amend = "commit --amend -m";
    };
  };
}
