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
      historyWidget.command = lib.mkIf config.programs.atuin.enable "";
      defaultCommand = "${lib.getExe pkgs.fd} --type=f --hidden --exclude=.git";
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
        theme_background = true;
        truecolor = true;
        presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      };
    };
    eza = {
      enable = true;
      enableNushellIntegration = false;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--hyperlink"
        "--follow-symlinks"
      ];
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
      enableNushellIntegration = true;
      daemon.enable = true;
    };
  };
  home.shellAliases = {
    tree = lib.mkForce "${lib.getExe config.programs.eza.package} --tree --icons=always";
  };
}
