{ pkgs-unstable, ... }:
let
  inherit (pkgs-unstable) nu_scripts;
in
{
  programs.nushell = {
    enable = true;
    package = pkgs-unstable.nushell;
    configFile.source = ./config.nu;
    extraConfig = ''
      # completion
      use ${nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/tar/tar-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/rg/rg-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/pnpm/pnpm-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/make/make-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
      # alias
      # use ${nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu *
      use ${nu_scripts}/share/nu_scripts/aliases/eza/eza-aliases.nu *
      use ${nu_scripts}/share/nu_scripts/aliases/bat/bat-aliases.nu *
    '';
  };
}
