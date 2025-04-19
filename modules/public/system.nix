{username, ...}: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    builders-use-substitutes = true;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
