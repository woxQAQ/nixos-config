{ self, lib, ... }:
{
  perSystem =
    { system, ... }:
    let
      # Use the hosts' package sets so overlays and module overrides match consumers.
      host =
        {
          x86_64-linux = self.nixosConfigurations.woxQAQ;
          aarch64-darwin = self.darwinConfigurations.woxMac;
        }
        .${system};
      inherit (host) pkgs;
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      home = host.config.home-manager.users.${if isLinux then "woxQAQ" else "woxqaq"};
      hidpipe =
        if isLinux then host.config.services.hidpipe else home.services.hidpipe;
      localPackages = lib.genAttrs [
        "agent-skills"
        "chillroundf"
        "delta-bin"
        "flclash"
        "helix"
        "inter-noto-sans-sc"
        "ioskeley-chillround"
        "magpie"
        "obelisk-cli"
        "removemacai"
        "resource-han-rounded"
        "yozai-font"
        "zed-editor-bin"
      ] (name: pkgs.${name});
      extraPackages = {
        dbeaver-bin = home.programs.dbeaver.package;
        hidpipe = hidpipe.package;
        v2dat = pkgs.callPackage ../pkg/v2dat { };
      }
      // lib.optionalAttrs isLinux {
        sparkle = pkgs.callPackage ../pkg/sparkle { };
        waydroid-helper = pkgs.callPackage ../pkg/waydroid-helper { };
      }
      // lib.optionalAttrs hidpipe.openlogi.enable {
        hidpipe-openlogi = hidpipe.openlogi.package;
      };
    in
    {
      packages = lib.filterAttrs (
        _: package: lib.meta.availableOn pkgs.stdenv.hostPlatform package
      ) (localPackages // extraPackages);
    };
}
