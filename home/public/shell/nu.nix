{
  nu_scripts,
  pkgs,
  lib,
  config,
  osConfig ? { },
  ...
}:
let
  privateConfigEnabled = lib.hasAttrByPath [
    "environment"
    "etc"
    "agenix/private.nu"
  ] osConfig;
  baseConfig = # nu
    ''
      # Only load the private module on hosts that provision it.
      ${lib.optionalString privateConfigEnabled "source /etc/agenix/private.nu"}
      # completion
      const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}' '${./custom_completions}']
      use custom-completions/git/git-completions.nu *
      use ${./custom_completions/git/submodule.nu} *
      use custom-completions/gh/gh-completions.nu *
      use custom-completions/tldr/tldr-completions.nu *
      use custom-completions/tar/tar-completions.nu *
      use custom-completions/zellij/zellij-completions.nu *
      use custom-completions/docker/docker-completions.nu *
      use custom-completions/uv/uv-completions.nu *
      use custom-completions/just/just-completions.nu *
      source go/go.nu
      use custom-completions/rg/rg-completions.nu *
      source pnpm/pnpm.nu
      use custom-completions/make/make-completions.nu *
      use custom-completions/npm/npm-completions.nu *
      use custom-completions/man/man-completions.nu *
      use custom-completions/nix/nix-completions.nu *
      use custom-completions/ssh/ssh-completions.nu *
      use custom-completions/cargo/cargo-completions.nu *
      use custom-completions/curl/curl-completions.nu *
      # alias
      use aliases/git/git-aliases.nu *
      use aliases/eza/eza-aliases.nu *
      use aliases/bat/bat-aliases.nu *

      # Keep argx namespaced because it exports a `parse` command that would
      # shadow Nushell's built-in `parse` used by the fzf integration.
      use modules/argx
      use modules/lg *
      use modules/kubernetes *
    '';
in
{
  programs.nushell = {
    enable = true;
    # Reload the current generation even when a parent shell sourced an older one.
    # Bash preserves Home Manager's POSIX variable expansion and search paths.
    extraEnv = # nu
      ''
        load-env (
          ^${pkgs.bash}/bin/bash --noprofile --norc -e -c '
            unset __HM_SESS_VARS_SOURCED
            source "$1"
            ${pkgs.coreutils}/bin/env -0
          ' home-manager ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
          | split row (char nul)
          | parse --regex '(?s)^(?<name>[^=]+)=(?<value>.*)$'
          | where name not-in [PWD FILE_PWD CURRENT_FILE NU_VERSION SHLVL _]
          | reduce --fold {} {|entry, vars| $vars | insert $entry.name $entry.value }
          | update PATH {|vars| $vars.PATH | split row (char esep) | uniq }
        )
      '';
    configFile.source = ./config.nu;
    plugins = with pkgs.nushellPlugins; [
      query
      formats
    ];
    extraConfig = # nu
      ''
        ${baseConfig}
      '';
  };
}
