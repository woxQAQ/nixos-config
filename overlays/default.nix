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

  modifications = _final: prev: {
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
    # In-house Go port of ryan4yin/pyclipsync: Wayland <-> X11 clipboard
    # sync for xwayland-satellite setups (niri).
    clipsync = prev.callPackage ../pkg/clipsync { };
    # Vendored from nixpkgs: upstream removed flclash as unmaintained.
    flclash = prev.callPackage ../pkg/flclash { };
    inter-noto-sans-sc = prev.callPackage ../pkg/inter-noto-sans-sc { };
    magpie = prev.callPackage ../pkg/magpie { };
    obelisk-cli = prev.callPackage ../pkg/obelisk-cli { };
    removemacai = prev.callPackage ../pkg/removemacai { };
    yozai-font = prev.callPackage ../pkg/yozai-font { };
    resource-han-rounded = prev.callPackage ../pkg/resource-han-rounded { };
    zed-editor-bin = prev.callPackage ../pkg/zed-editor-bin { };
  };
}
