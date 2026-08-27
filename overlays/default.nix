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
    # Home Manager still references deprecated xorg aliases.
    xorg = prev.xorg // {
      inherit (prev) lndir;
      inherit (prev) xrdb;
    };

    # v2.0.0 ships fonts without glyph names (post format 3), which breaks
    # ligature rendering in kitty; fixed upstream in v2.1.0.
    # TODO: should be removed after nixpkgs bump version
    ioskeley-mono = prev.ioskeley-mono // {
      normal-term-NF = prev.ioskeley-mono.normal-term-NF.overrideAttrs {
        version = "v2.1.0";
        src = prev.fetchzip {
          url = "https://github.com/ahatem/IoskeleyMono/releases/download/v2.1.0/IoskeleyMono-Term-NerdFont.zip";
          stripRoot = false;
          hash = "sha256-joAhNADErBErDqTrNelJ0ulGZCN/OUZ1SMYyU++7l6U=";
        };
      };
    };
  };
}
