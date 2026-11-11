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
      # TODO: remove this after upstream fix
      # fzf 0.74.5's embedded nushell completion script registers its wrapper
      # completer with the legacy positional `spans` input, which Nushell
      # 0.116+ warns about on every prompt. fzf master already migrated to the
      # record input; backport that section until a release carries it.
      package = pkgs.fzf.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./shell/patches/fzf-nushell-completer.patch
        ];
      });
      historyWidget.command = lib.mkIf config.programs.atuin.enable "";
      defaultCommand = "${lib.getExe pkgs.fd} --type=f --hidden --follow --strip-cwd-prefix --exclude=.git";
      defaultOptions = [
        "--layout=reverse" # Top-first.
        "--exact" # Substring matching by default, `'`-quote for subsequence matching.
        "--bind=alt-p:toggle-preview,alt-a:select-all"
        "--multi"
        "--no-mouse"
        "--info=inline"

        # Style and widget layout
        "--ansi"
        "--with-nth=1.."
        "--pointer=' '"
        "--header-first"
        "--border=rounded"
      ];
    };
    ripgrep = {
      enable = true;
      package = pkgs.ripgrep;
      arguments = [
        "--glob=!.git/*"
        "--smart-case"
      ];
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
        style = "auto,header-filesize";
      };
      extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        with pkgs.bat-extras;
        [
          batdiff
          batgrep
          batman
          batpipe
          batwatch
          prettybat
        ]
      );
    };
    btop = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.btop else null;
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
      # Native autostart serializes startup and removes stale sockets on macOS;
      # launchd's direct `daemon start` cannot recover from a leftover socket.
      daemon.enable = !pkgs.stdenv.hostPlatform.isDarwin;
      settings.daemon = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        enabled = true;
        autostart = true;
      };
    };
  };
  home.shellAliases = {
    tree = lib.mkForce "${lib.getExe config.programs.eza.package} --tree --icons=always";
  };
  home.packages = with pkgs; [
    ups
    glow
  ];
}
