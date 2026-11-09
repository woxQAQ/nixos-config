{
  pkgs,
  home-manager,
  catppuccin,
}:
let
  inherit (pkgs) lib;
  home = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit catppuccin; };
    modules = [
      ./default.nix
      {
        home = {
          username = "theme-check";
          homeDirectory = "/tmp/catppuccin-check";
          stateVersion = "26.05";
        };
        catppuccin = {
          enable = true;
          autoEnable = true;
          appearance = "auto";
        };
        programs =
          lib.genAttrs
            [
              "atuin"
              "bat"
              "btop"
              "delta"
              "eza"
              "fzf"
              "ghostty"
              "helix"
              "k9s"
              "lazygit"
              "nushell"
              "tmux"
              "yazi"
              "zellij"
            ]
            (_: {
              enable = true;
            })
          // {
            delta = {
              enable = true;
              enableGitIntegration = true;
            };
            fzf = {
              enable = true;
              enableNushellIntegration = false;
            };
            atuin = {
              enable = true;
              enableNushellIntegration = false;
            };
          };
      }
    ];
  };
  inherit (home) config;
  static =
    (home.extendModules {
      modules = [ { catppuccin.appearance = lib.mkForce "static"; } ];
    }).config;
  disabled =
    (home.extendModules {
      modules = [ { catppuccin.enable = lib.mkForce false; } ];
    }).config;
  mixed =
    (home.extendModules {
      modules = [
        {
          catppuccin.bat.appearance = "static";
          catppuccin.helix.flavor = "frappe";
          catppuccin.fzf.enable = false;
        }
      ];
    }).config;
  apply = lib.findFirst (
    package: (package.name or "") == "catppuccin-apply"
  ) (throw "Missing appearance command") config.home.packages;
  watch = builtins.head (
    lib.toList config.systemd.user.services.catppuccin-appearance.Service.ExecStart
  );
  hook = pkgs.writeText "catppuccin-prompt.nu" (
    lib.replaceStrings
      [ ''"${config.xdg.configHome}/catppuccin/current/appearance"'' ]
      [ ''($env.XDG_CONFIG_HOME | path join "catppuccin/current/appearance")'' ]
      config.programs.nushell.extraConfig
  );
  # Whole Home Manager evaluations exercise upstream option reuse and policy selection.
  valid =
    assert config.programs.bat.config.theme == "auto";
    assert
      config.programs.ghostty.settings.theme
      == [ "light:catppuccin-latte,dark:catppuccin-mocha" ];
    assert config.programs.zellij.settings.theme_light == "catppuccin-latte";
    assert
      builtins.length (builtins.attrNames config.catppuccin.runtime.files) == 9;
    assert static.catppuccin.runtime.files == { };
    assert static.programs.bat.config.theme == "Catppuccin Mocha";
    assert !(static.systemd.user.services ? catppuccin-appearance);
    assert disabled.catppuccin.runtime.files == { };
    assert !(disabled.programs.bat.config ? theme);
    assert mixed.programs.bat.config.theme == "Catppuccin Mocha";
    assert mixed.programs.helix.settings.theme.dark == "catppuccin-frappe";
    assert !(mixed.catppuccin.runtime.files ? "fzf.rc");
    true;
in
assert valid;
pkgs.runCommand "catppuccin-appearance-check"
  {
    nativeBuildInputs = [
      apply
      pkgs.git
      pkgs.nushell
      pkgs.glib
      pkgs.util-linux
      pkgs.tmux
    ];
  }
  ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export TMUX_TMPDIR="$TMPDIR/tmux"
    mkdir -p "$HOME" "$TMUX_TMPDIR"

    catppuccin-apply light
    test "$(cat "$XDG_CONFIG_HOME/catppuccin/current/appearance")" = light
    test "$(git config --file "$XDG_CONFIG_HOME/catppuccin/current/delta.gitconfig" --get delta.features)" = catppuccin-latte
    for asset in "$XDG_CONFIG_HOME/catppuccin/current/"*; do
      test -r "$asset"
    done
    nu --no-config-file -c 'source ${
      config.catppuccin.runtime.files."nushell.nu".light
    }; if $env.config.color_config.string != "#40a02b" { error make {msg: "Incorrect light palette"} }'

    before=$(readlink "$XDG_CONFIG_HOME/catppuccin/current")
    catppuccin-apply light
    test "$before" = "$(readlink "$XDG_CONFIG_HOME/catppuccin/current")"
    if catppuccin-apply invalid; then
      echo "Invalid appearance unexpectedly accepted" >&2
      exit 1
    fi
    test "$before" = "$(readlink "$XDG_CONFIG_HOME/catppuccin/current")"

    catppuccin-apply dark
    test "$(cat "$XDG_CONFIG_HOME/catppuccin/current/appearance")" = dark
    test "$(git config --file "$XDG_CONFIG_HOME/catppuccin/current/delta.gitconfig" --get delta.features)" = catppuccin-mocha
    test "$before" != "$(readlink "$XDG_CONFIG_HOME/catppuccin/current")"
    nu --no-config-file -c 'source ${
      config.catppuccin.runtime.files."nushell.nu".dark
    }; if $env.config.color_config.string != "#a6e3a1" { error make {msg: "Incorrect dark palette"} }'

    catppuccin-apply light
    nu --no-config-file -c '
      source ${hook}
      do --env ($env.config.hooks.pre_prompt | first)
      if $env.config.color_config.string != "#40a02b" { error make {msg: "Prompt did not select light palette"} }
      ^${lib.getExe apply} dark
      do --env ($env.config.hooks.pre_prompt | first)
      if $env.config.color_config.string != "#a6e3a1" { error make {msg: "Running shell did not follow dark mode"} }
    '

    # The default server lives under an isolated socket directory in the sandbox.
    export TERM=xterm-256color
    tmux -f /dev/null new-session -d -s appearance -x 80 -y 24 '${pkgs.bash}/bin/bash --noprofile --norc'
    trap 'tmux kill-server 2>/dev/null || true' EXIT
    tmux source-file "$XDG_CONFIG_HOME/catppuccin/current/tmux.conf"
    catppuccin-apply dark
    test "$(tmux show-option -gqv @catppuccin_flavor)" = mocha
    test "$(tmux show-option -gqv @thm_bg)" = '#1e1e2e'
    catppuccin-apply light
    test "$(tmux show-option -gqv @catppuccin_flavor)" = latte
    test "$(tmux show-option -gqv @thm_bg)" = '#eff1f5'
    tmux kill-server
    trap - EXIT

    # An isolated keyfile backend exercises real GSettings monitor events.
    export GSETTINGS_BACKEND=keyfile
    export GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    catppuccin-apply light
    setsid ${watch} &
    watcher=$!
    trap 'kill -- -"$watcher" 2>/dev/null || true' EXIT
    for mode in dark light dark; do
      if [ "$mode" = light ]; then
        gsettings set org.gnome.desktop.interface color-scheme prefer-light
      else
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
      fi
      for _ in $(seq 1 100); do
        if [ "$(cat "$XDG_CONFIG_HOME/catppuccin/current/appearance")" = "$mode" ]; then
          break
        fi
        sleep 0.05
      done
      test "$(cat "$XDG_CONFIG_HOME/catppuccin/current/appearance")" = "$mode"
    done
    kill -- -"$watcher"
    wait "$watcher" || true
    trap - EXIT

    touch "$out"
  ''
