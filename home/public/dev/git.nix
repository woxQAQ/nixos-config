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
  home.packages = with pkgs; [
    gitbutler
  ];
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings.prompt = "enabled";
    };
    lazygit = {
      enable = true;
      enableNushellIntegration = true;
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = if pkgs.stdenv.isLinux then username else "woxQAQ";
        email = lib.mkDefault "woxqaq@gmail.com";
      };
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      trim.bases = "develop,master,main";
      pull.rebase = true;
      log.date = "iso";
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
      branch.sort = "committerdate";
      aliases = {
        p = "pull --ff-only";
        graph = "log --decorate --oneline --graph";
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
