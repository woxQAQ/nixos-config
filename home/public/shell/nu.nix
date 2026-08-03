{
  nu_scripts,
  nu_scripts_wox,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  aerospaceEnabled =
    pkgs.stdenv.hostPlatform.isDarwin
    && builtins.any (cask: cask.name == "aerospace") osConfig.homebrew.casks;
  baseConfig = # nu
    ''
      # completion
      source /etc/agenix/private.nu
      const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}' '${nu_scripts_wox}']
      ${lib.optionalString aerospaceEnabled "use custom-completions/aerospace/aerospace-completions.nu *"}
      use custom-completions/git/git-completions.nu *
      use custom-completions/gh/gh-completions.nu *
      use custom-completions/tldr/tldr-completions.nu *
      use custom-completions/tar/tar-completions.nu *
      use custom-completions/zellij/zellij-completions.nu *
      use custom-completions/docker/docker-completions.nu *
      use custom-completions/uv/uv-completions.nu *
      use custom-completions/go/go-completions.nu *
      use custom-completions/rg/rg-completions.nu *
      use custom-completions/pnpm/pnpm-completions.nu *
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
