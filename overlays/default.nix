{ inputs, ... }:
let
  mkNixpkgs =
    nixpkgs: system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
in
{
  package-sets = final: _prev: {
    fast = mkNixpkgs inputs.nixpkgs-fast final.system;
    stable = mkNixpkgs inputs.nixpkgs-stable final.system;
    unstable = mkNixpkgs inputs.nixpkgs-unstable final.system;
  };

  modifications = final: prev: {
    helix =
      inputs.helix.packages.${prev.stdenv.hostPlatform.system}.default.override
        {
          # The pinned Cylc grammar repository is no longer publicly available.
          includeGrammarIf = grammar: grammar.name != "cylc";
          grammarOverlays = [
            (_final: grammars: {
              perl = grammars.perl.overrideAttrs (old: {
                # glibc 2.44 defines bsearch as a C23 macro; keep the scanner's
                # bundled implementation private to avoid the libc name collision.
                postPatch = (old.postPatch or "") + ''
                  substituteInPlace src/bsearch.c \
                    --replace-fail 'void *bsearch(' 'static void *tsp_bsearch('
                  substituteInPlace src/tsp_unicode.h \
                    --replace-fail 'return bsearch(' 'return tsp_bsearch('
                '';
              });
            })
          ];
        };

    # Home Manager still references deprecated xorg aliases.
    xorg = prev.xorg // {
      inherit (prev) lndir;
      inherit (prev) xrdb;
    };

    # In-tree packages from pkg/, exposed as pkgs.<name>.
    agent-skills = prev.callPackage ../pkg/agent-skills { };
    chillroundf = prev.callPackage ../pkg/chillroundf { };
    delta-bin = prev.callPackage ../pkg/delta-bin { };
    # Vendored from nixpkgs: upstream removed flclash as unmaintained.
    flclash = prev.callPackage ../pkg/flclash { };
    # Browser sign-in is broken until the Linux protocol branch lands upstream;
    # the same override also fixes the Wayland flags the C wrapper mangled.
    github-desktop = prev.callPackage ../pkg/github-desktop {
      inherit (prev) github-desktop electron;
    };
    inter-noto-sans-sc = prev.callPackage ../pkg/inter-noto-sans-sc { };
    ioskeley-chillround = prev.callPackage ../pkg/ioskeley-chillround { };
    # Vendored from nixpkgs: upstream package is unmaintained and stuck at 5.x.
    maa-assistant-arknights = prev.callPackage ../pkg/maa-assistant-arknights { };
    # Vendored from nixpkgs: stuck at 0.5.x; link the vendored core instead of
    # the equally stale nixpkgs one.
    maa-cli = prev.callPackage ../pkg/maa-cli {
      inherit (final)
        maa-assistant-arknights
        ;
    };
    magpie = prev.callPackage ../pkg/magpie { };
    neuve = prev.callPackage ../pkg/neuve { };
    obelisk-cli = prev.callPackage ../pkg/obelisk-cli { };
    otelcol = prev.callPackage ../pkg/otelcol { };
    removemacai = prev.callPackage ../pkg/removemacai { };
    yozai-font = prev.callPackage ../pkg/yozai-font { };
    resource-han-rounded = prev.callPackage ../pkg/resource-han-rounded { };
    zed-editor-bin = prev.callPackage ../pkg/zed-editor-bin { };
  };
}
