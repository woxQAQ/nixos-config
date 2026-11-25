{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.catppuccin.runtime;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  enabled = cfg.files != { };
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
        flock
      ]
      ++ lib.optionals isLinux [
        glib
        procps
      ]
      ++ lib.optional config.programs.tmux.enable tmux;
    text = ''
      ${lib.optionalString isLinux ''
        export GSETTINGS_SCHEMA_DIR=${schemas}
        export GIO_EXTRA_MODULES=${pkgs.dconf.lib}/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}
      ''}
      mode="''${1:-}"
      if [ -z "$mode" ]; then
        ${
          if isLinux then
            ''
              preference=$(gsettings get org.gnome.desktop.interface color-scheme)
              case "$preference" in
                "'prefer-dark'") mode=dark ;;
                *) mode=light ;;
              esac
            ''
          else
            ''
              # macOS has no GSettings; the global domain only reports Dark in
              # dark mode. catppuccin-probe overrides this per shell session.
              if /usr/bin/defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
                mode=dark
              else
                mode=light
              fi
            ''
        }
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
      ${lib.optionalString (cfg.files ? "btop.theme") (
        if isLinux then
          ''
            # btop reloads its configuration and theme on SIGUSR2.
            pkill --euid "$(id -u)" --exact --signal USR2 btop || [ "$?" -eq 1 ]
          ''
        else
          ''
            # btop reloads its configuration and theme on SIGUSR2.
            /usr/bin/pkill -USR2 -x btop || [ "$?" -eq 1 ]
          ''
      )}
      ${lib.optionalString (cfg.files ? "tmux.conf") ''
        if tmux list-sessions >/dev/null 2>&1; then
          tmux source-file "$state_dir/current/tmux.conf"
        fi
      ''}
    '';
  };
  # macOS has no desktop bridge, and over SSH the Mac's own appearance is not
  # authoritative anyway: the client's terminal is. Probing the terminal
  # background covers local and remote sessions with one mechanism.
  probe = pkgs.writeShellApplication {
    name = "catppuccin-probe";
    text = ''
      case "''${TERM:-dumb}" in
        dumb) exit 0 ;;
      esac
      { exec 3<>/dev/tty; } 2>/dev/null || exit 0

      saved=$(stty -g <&3) || exit 0
      restore() { stty "$saved" <&3 2>/dev/null || :; }
      trap restore EXIT
      stty raw -echo <&3

      # Ask for the background colour; accept either response terminator.
      printf '%s' $'\e]11;?\e\\' >&3
      response=
      while IFS= read -r -n 1 -t 1 char <&3; do
        response+="$char"
        case "$response" in
          *$'\a'|*$'\033\\') break ;;
        esac
      done
      restore
      trap - EXIT

      channels=$(printf '%s' "$response" | sed -n 's/.*rgb:\([0-9A-Fa-f]\{1,4\}\)\/\([0-9A-Fa-f]\{1,4\}\)\/\([0-9A-Fa-f]\{1,4\}\).*/\1 \2 \3/p')
      if [ -z "$channels" ]; then
        exit 0
      fi
      read -r red green blue <<<"$channels"
      if [ -z "$red" ] || [ -z "$green" ] || [ -z "$blue" ]; then
        exit 0
      fi

      # Channels arrive as 1-4 hex digits; the leading two carry the weight.
      r=$((16#''${red:0:2}))
      g=$((16#''${green:0:2}))
      b=$((16#''${blue:0:2}))
      luminance=$(( (299 * r + 587 * g + 114 * b) / 1000 ))
      if [ "$luminance" -gt 127 ]; then
        mode=light
      else
        mode=dark
      fi

      state_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/catppuccin"
      current=$(cat "$state_dir/current/appearance" 2>/dev/null || :)
      if [ "$mode" = "$current" ]; then
        exit 0
      fi
      exec ${lib.getExe apply} "$mode"
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

  config = lib.mkMerge [
    (lib.mkIf enabled {
      home.packages = [ apply ] ++ lib.optional isDarwin probe;
      home.activation.catppuccinAppearance =
        lib.hm.dag.entryAfter [ "linkGeneration" ]
          ''
            run env XDG_CONFIG_HOME=${lib.escapeShellArg config.xdg.configHome} ${lib.getExe apply}
          '';
      programs.nushell.extraConfig =
        lib.mkIf (isDarwin && config.programs.nushell.enable)
          (
            lib.mkBefore # nu
              ''
                # No desktop bridge exists on macOS; probe this terminal's
                # background once per session so SSH clients drive the selection.
                if ($env.CATPPUCCIN_PROBE_DONE? | is-empty) {
                  $env.CATPPUCCIN_PROBE_DONE = "1"
                  do -i { ^${lib.getExe probe} }
                }
              ''
          );
    })
    (lib.mkIf (enabled && isLinux) {
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
    })
  ];
}
