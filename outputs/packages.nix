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
      # Cache source builds, including the OpenLogi component used by hidpipe.
      packages = {
        inherit (pkgs) helix;
        hidpipe = hidpipe.package;
      }
      // lib.optionalAttrs isLinux {
        inherit (pkgs) flclash;
      }
      // lib.optionalAttrs hidpipe.openlogi.enable {
        hidpipe-openlogi = hidpipe.openlogi.package;
      };
    in
    {
      inherit packages;
    };
}
