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

    # In-tree packages from pkg/, exposed as pkgs.<name>.
    chillroundf = prev.callPackage ../pkg/chillroundf { };
    removemacai = prev.callPackage ../pkg/removemacai { };
    yozai-font = prev.callPackage ../pkg/yozai-font { };
    resource-han-rounded = prev.callPackage ../pkg/resource-han-rounded { };
    zed-editor-bin = prev.callPackage ../pkg/zed-editor-bin { };
  };
}
