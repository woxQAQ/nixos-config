{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.catppuccin.runtime;
  enabled = pkgs.stdenv.hostPlatform.isLinux && cfg.files != { };
  schemas = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
  bundle =
    mode:
    pkgs.linkFarm "catppuccin-${mode}" (
      [
        {
          name = "appearance";
          path = pkgs.writeText "catppuccin-appearance" mode;
        }
      ]
      ++ lib.mapAttrsToList (name: value: {
        inherit name;
        path = value.${mode};
      }) cfg.files
    );
  apply = pkgs.writeShellApplication {
    name = "catppuccin-apply";
    runtimeInputs =
      with pkgs;
      [
        coreutils
        util-linux
        glib
        procps
      ]
      ++ lib.optional config.programs.tmux.enable tmux;
    text = ''
      export GSETTINGS_SCHEMA_DIR=${schemas}
      export GIO_EXTRA_MODULES=${pkgs.dconf.lib}/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}
      mode="''${1:-}"
      if [ -z "$mode" ]; then
        preference=$(gsettings get org.gnome.desktop.interface color-scheme)
        case "$preference" in
          "'prefer-dark'") mode=dark ;;
          *) mode=light ;;
        esac
      fi
      case "$mode" in
        light) target=${bundle "light"} ;;
        dark) target=${bundle "dark"} ;;
        *) echo "Usage: catppuccin-apply [light|dark]" >&2; exit 2 ;;
      esac

      state_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/catppuccin"
      mkdir -p "$state_dir"
      exec 9>"$state_dir/.lock"
      flock 9
      if [ "$(readlink "$state_dir/current" || true)" != "$target" ]; then
        temporary=$(mktemp -d "$state_dir/.switch.XXXXXX")
        trap 'rm -rf "$temporary"' EXIT
        ln -s "$target" "$temporary/current"
        mv -Tf "$temporary/current" "$state_dir/current"
      fi

      # Reconcile clients even when a previous reload failed after the link switched.
      ${lib.optionalString (cfg.files ? "btop.theme") ''
        # btop reloads its configuration and theme on SIGUSR2.
        pkill --euid "$(id -u)" --exact --signal USR2 btop || [ "$?" -eq 1 ]
      ''}
      ${lib.optionalString (cfg.files ? "tmux.conf") ''
        if tmux list-sessions >/dev/null 2>&1; then
          tmux source-file "$state_dir/current/tmux.conf"
        fi
      ''}
    '';
  };
  python = pkgs.python3.withPackages (packages: [ packages.pygobject3 ]);
  watch = pkgs.writeShellApplication {
    name = "catppuccin-watch";
    text = ''
      export GSETTINGS_SCHEMA_DIR=${schemas}
      export GIO_EXTRA_MODULES=${pkgs.dconf.lib}/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}
      export GI_TYPELIB_PATH=${pkgs.glib.out}/lib/girepository-1.0
      exec ${python}/bin/python ${./watch.py} ${lib.getExe apply}
    '';
  };
in
{
  options.catppuccin.runtime.files = lib.mkOption {
    internal = true;
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          light = lib.mkOption { type = lib.types.path; };
          dark = lib.mkOption { type = lib.types.path; };
        };
      }
    );
    description = "Theme assets selected atomically by the desktop appearance service.";
  };

  config = lib.mkIf enabled {
    home.packages = [ apply ];
    home.activation.catppuccinAppearance =
      lib.hm.dag.entryAfter [ "linkGeneration" ]
        ''
          run env XDG_CONFIG_HOME=${lib.escapeShellArg config.xdg.configHome} ${lib.getExe apply}
        '';
    systemd.user.services.catppuccin-appearance = {
      Unit = {
        Description = "Follow desktop appearance with Catppuccin themes";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe watch;
        Environment = "XDG_CONFIG_HOME=${config.xdg.configHome}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
