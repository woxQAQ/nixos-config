{
  config,
  lib,
  pkgs,
  ...
}:
let
  atuinSocket = "${config.xdg.dataHome}/atuin/daemon.sock";
  atuinLogDir = "${config.home.homeDirectory}/Library/Logs";
in
{
  programs = {
    fzf = {
      enable = true;
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
      enableNushellIntegration = true;
      daemon.enable = true;
    };
  };

  launchd.agents.atuin-daemon = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = lib.mkForce [
        "/bin/sh"
        "-lc"
        ''
          mkdir -p ${lib.escapeShellArg "${config.xdg.dataHome}/atuin"} ${lib.escapeShellArg atuinLogDir}
          if [ -S ${lib.escapeShellArg atuinSocket} ] && ! ${pkgs.lsof}/bin/lsof -U ${lib.escapeShellArg atuinSocket} >/dev/null 2>&1; then
            rm -f ${lib.escapeShellArg atuinSocket}
          fi
          exec ${lib.getExe config.programs.atuin.package} daemon
        ''
      ];
      RunAtLoad = true;
      StandardOutPath = "${atuinLogDir}/org.nix-community.home.atuin-daemon.stdout.log";
      StandardErrorPath = "${atuinLogDir}/org.nix-community.home.atuin-daemon.stderr.log";
    };
  };
}
