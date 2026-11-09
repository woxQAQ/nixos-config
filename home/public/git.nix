{
  username,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-notify # notifications
        gh-eco # explore the ecosystem
        gh-cal # contributions calender terminal viewer
        gh-poi # clean up local branches safely
        gh-stack # stacked pull requests

        gh-markdown-preview
      ];
      settings.prompt = "enabled";
    };

    gh-dash = {
      enable = true;
      settings = {
        prSections = [
          {
            title = "Needs my review";
            filters = "is:open review-requested:@me";
          }
          {
            title = "My PRs";
            filters = "is:open author:@me";
          }
          {
            title = "Involved";
            filters = "is:open involves:@me -author:@me";
          }
          {
            title = "Stale";
            filters = "is:open involves:@me updated:<{{ nowModify \"-14d\" }}";
          }
        ];
      };
    };
    lazygit = {
      enable = true;
      enableNushellIntegration = true;
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
      };
    };

    mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = "openpgp";
    settings = {
      user = {
        name = if pkgs.stdenv.hostPlatform.isLinux then username else "woxQAQ";
        email = lib.mkDefault "woxqaq@gmail.com";
      };
      fetch = {
        prune = true;
        pruneTags = true;
      };
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      trim.bases = "develop,master,main";
      pull.rebase = true;
      log.date = "iso";
      merge.conflictStyle = lib.mkForce "zdiff3";
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
}
