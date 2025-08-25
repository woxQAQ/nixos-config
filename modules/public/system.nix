{
  # nixpkgs.overlays = import mylib.flakeRoot "overlays";
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    builders-use-substitutes = true;

    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
