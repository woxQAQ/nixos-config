{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs = {
    fzf = {
      enable = true;
      historyWidget.command = "";
    };
    # a tldr alternate
    tealdeer = {
      enable = true;
      enableAutoUpdates = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates = {
          auto_update = false;
          auto_update_interval_hours = 720;
        };
      };
    };
    tmux = {
      enable = true;
      mouse = true;
    };
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    btop = {
      enable = true;
      settings = {
        theme_background = false; # make btop transparent
      };
    };
    eza = {
      enable = true;
      enableNushellIntegration = false;
      git = true;
      icons = "auto";
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = false;
      daemon.enable = true;
    };

    nushell.extraConfig = ''
      source ${
        pkgs.runCommand "atuin-nushell-config.nu" { } ''
          export HOME=$TMPDIR
          export XDG_CONFIG_HOME=$TMPDIR/.config
          ${lib.getExe config.programs.atuin.package} init nu > $out
        ''
      }
    '';
  };
}
