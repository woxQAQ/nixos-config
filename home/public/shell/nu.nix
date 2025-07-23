{
  pkgs,
  unstable-pkg,
  username,
  ...
}:
let
  inherit (unstable-pkg) nu_scripts;
in
{
  programs.nushell = {
    enable = pkgs.stdenv.isLinux;
    package = unstable-pkg.nushell;
    configFile.source = ./config.nu;
    extraConfig = # nu
      ''
        # completion
        const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}/share/nu_scripts']
        use custom-completions/git/git-completions.nu *
        use custom-completions/tar/tar-completions.nu *
        use custom-completions/rg/rg-completions.nu *
        use custom-completions/pnpm/pnpm-completions.nu *
        use custom-completions/make/make-completions.nu *
        use custom-completions/man/man-completions.nu *
        use custom-completions/nix/nix-completions.nu *
        # alias
        use aliases/git/git-aliases.nu *
        use aliases/eza/eza-aliases.nu *
        use aliases/bat/bat-aliases.nu *

        use modules/argx *
        use modules/lg *
        use modules/kubernetes *
      '';
  };
}
