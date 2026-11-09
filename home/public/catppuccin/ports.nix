let
  native = configure: {
    runtime = false;
    inherit configure;
  };
  runtime = configure: {
    runtime = true;
    inherit configure;
  };
  pair = cfg: name: source: {
    ${name} = {
      light = source cfg.lightFlavor;
      dark = source cfg.flavor;
    };
  };
in
{
  bat = native (
    {
      config,
      lib,
      cfg,
      ...
    }:
    let
      names = map (flavor: "Catppuccin ${lib.toSentenceCase flavor}") [
        cfg.lightFlavor
        cfg.flavor
      ];
    in
    {
      programs.bat = {
        config = {
          theme = "auto";
          theme-light = builtins.head names;
          theme-dark = builtins.elemAt names 1;
        };
        themes = lib.genAttrs names (name: {
          src = config.catppuccin.sources.bat;
          file = "${name}.tmTheme";
        });
      };
    }
  );

  ghostty = native (
    {
      config,
      lib,
      cfg,
      ...
    }:
    {
      programs.ghostty.settings.theme = "light:catppuccin-${cfg.lightFlavor},dark:catppuccin-${cfg.flavor}";
      xdg.configFile =
        lib.genAttrs
          (map (f: "ghostty/themes/catppuccin-${f}") [
            cfg.lightFlavor
            cfg.flavor
          ])
          (name: {
            source = "${config.catppuccin.sources.ghostty}/${builtins.baseNameOf name}.conf";
          });
    }
  );

  helix = native (
    {
      config,
      cfg,
      ...
    }:
    {
      programs.helix.settings.theme = {
        light = "catppuccin-${cfg.lightFlavor}";
        dark = "catppuccin-${cfg.flavor}";
      };
      xdg.configFile = builtins.listToAttrs (
        map
          (flavor: {
            name = "helix/themes/catppuccin-${flavor}.toml";
            value.source = "${config.catppuccin.sources.helix}/${
              if cfg.useItalics then "default" else "no_italics"
            }/catppuccin_${flavor}.toml";
          })
          [
            cfg.lightFlavor
            cfg.flavor
          ]
      );
    }
  );

  yazi = native (
    {
      config,
      lib,
      pkgs,
      cfg,
      ...
    }:
    {
      programs.yazi = {
        theme.flavor = {
          light = "catppuccin-${cfg.lightFlavor}";
          dark = "catppuccin-${cfg.flavor}";
        };
        flavors = builtins.listToAttrs (
          map
            (flavor: {
              name = "catppuccin-${flavor}";
              value = pkgs.runCommand "yazi-catppuccin-${flavor}-${cfg.accent}" { } ''
                mkdir -p "$out"
                substitute ${config.catppuccin.sources.yazi}/${flavor}/catppuccin-${flavor}-${cfg.accent}.toml "$out/flavor.toml" \
                  --replace-fail 'syntect_theme = "~/.config/yazi/Catppuccin-${flavor}.tmTheme"' ""
                cp '${config.catppuccin.sources.bat}/Catppuccin ${lib.toSentenceCase flavor}.tmTheme' "$out/tmtheme.xml"
              '';
            })
            [
              cfg.lightFlavor
              cfg.flavor
            ]
        );
      };
    }
  );

  zellij = native (
    { cfg, ... }: {
      programs.zellij.settings = {
        theme_light = "catppuccin-${cfg.lightFlavor}";
        theme_dark = "catppuccin-${cfg.flavor}";
      };
    }
  );

  btop = runtime (
    {
      config,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "btop.theme" (
        f: "${config.catppuccin.sources.btop}/catppuccin_${f}.theme"
      );
      programs.btop.settings.color_theme = "${runtimePath}/btop.theme";
    }
  );

  fzf = runtime (
    {
      config,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "fzf.rc" (
        f: "${config.catppuccin.sources.fzf}/catppuccin-fzf-${f}.rc"
      );
      home.sessionVariables.FZF_DEFAULT_OPTS_FILE = "${runtimePath}/fzf.rc";
    }
  );

  eza = runtime (
    {
      config,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "eza.yml" (
        f: "${config.catppuccin.sources.eza}/${f}/catppuccin-${f}-${cfg.accent}.yml"
      );
      xdg.configFile."eza/theme.yml".source =
        config.lib.file.mkOutOfStoreSymlink "${runtimePath}/eza.yml";
    }
  );

  atuin = runtime (
    {
      config,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "atuin.toml" (
        f: "${config.catppuccin.sources.atuin}/${f}/catppuccin-${f}-${cfg.accent}.toml"
      );
      programs.atuin.settings.theme.name = "catppuccin-auto";
      xdg.configFile."atuin/themes/catppuccin-auto.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${runtimePath}/atuin.toml";
    }
  );

  k9s = runtime (
    {
      config,
      lib,
      pkgs,
      cfg,
      runtimePath,
      ...
    }:
    let
      xdg = !pkgs.stdenv.hostPlatform.isDarwin || config.xdg.enable;
      directory =
        if xdg then "k9s/skins" else "Library/Application Support/k9s/skins";
    in
    {
      catppuccin.runtime.files = pair cfg "k9s.yaml" (
        f:
        "${config.catppuccin.sources.k9s}/catppuccin-${f}${lib.optionalString cfg.transparent "-transparent"}.yaml"
      );
      programs.k9s.settings.k9s.ui.skin = "catppuccin-auto";
      xdg.configFile.${directory + "/catppuccin-auto.yaml"}.source =
        config.lib.file.mkOutOfStoreSymlink "${runtimePath}/k9s.yaml";
    }
  );

  lazygit = runtime (
    {
      config,
      lib,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "lazygit.yml" (
        f: "${config.catppuccin.sources.lazygit}/${f}/${cfg.accent}.yml"
      );
      home.sessionVariables.LG_CONFIG_FILE = lib.concatStringsSep "," (
        [ "${runtimePath}/lazygit.yml" ]
        ++ lib.optional (
          config.programs.lazygit.settings != { }
        ) "${config.xdg.configHome}/lazygit/config.yml"
      );
    }
  );

  delta = runtime (
    {
      config,
      lib,
      pkgs,
      cfg,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "delta.gitconfig" (
        f:
        pkgs.writeText "catppuccin-delta-${f}.gitconfig" ''
          [include]
            path = ${config.catppuccin.sources.delta}/catppuccin.gitconfig
          [delta]
            features = catppuccin-${f}
        ''
      );
      programs.git.includes = lib.mkIf config.programs.delta.enableGitIntegration [
        { path = "${config.xdg.configHome}/catppuccin/current/delta.gitconfig"; }
      ];
    }
  );

  nushell = runtime (
    {
      config,
      lib,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "nushell.nu" (
        f: "${config.catppuccin.sources.nushell}/catppuccin_${f}.nu"
      );
      programs.nushell.extraConfig =
        lib.mkBefore # nu
          ''
            def --env catppuccin-light [] {
              source ${config.catppuccin.sources.nushell}/catppuccin_${cfg.lightFlavor}.nu
            }
            def --env catppuccin-dark [] {
              source ${config.catppuccin.sources.nushell}/catppuccin_${cfg.flavor}.nu
            }
            # Sources are parsed once; the hook selects their pre-parsed commands.
            $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {
              let appearance = (try { open --raw "${runtimePath}/appearance" | str trim } catch { "dark" })
              if $appearance != ($env.CATPPUCCIN_APPEARANCE? | default "") {
                if $appearance == "light" { catppuccin-light } else { catppuccin-dark }
                $env.CATPPUCCIN_APPEARANCE = $appearance
              }
            })
          '';
    }
  );

  tmux = runtime (
    {
      config,
      pkgs,
      cfg,
      runtimePath,
      ...
    }:
    {
      catppuccin.runtime.files = pair cfg "tmux.conf" (
        f:
        let
          colors = pkgs.runCommand "catppuccin-tmux-${f}-colors.conf" { } ''
            # Upstream defaults use -o, which keeps the previous flavor's colors.
            substitute ${builtins.dirOf config.catppuccin.sources.tmux.rtp}/themes/catppuccin_${f}_tmux.conf "$out" \
              --replace-fail 'set -ogq' 'set -gq'
          '';
        in
        pkgs.writeText "catppuccin-tmux-${f}.conf" ''
          set -g @catppuccin_flavor '${f}'
          source-file ${colors}
          ${cfg.extraConfig}
          run-shell '${pkgs.bash}/bin/bash ${config.catppuccin.sources.tmux.rtp}'
        ''
      );
      programs.tmux.extraConfig = "source-file ${runtimePath}/tmux.conf";
    }
  );
}
