{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    git-lfs
    fastfetch
    lsof

    wget
    curl
    aria2
    nmap

    gnutar
    which
    tree
    rsync
    file

    gnumake
    killall
    pkgs.nixfmt-rfc-style

    zip
    unar
    unzipNLS
    xz
    p7zip
    zstd

    gnugrep
    gnused
    gawk
    jq

  ];
  environment.variables.EDITOR = "vim";
  nix.settings.substituters = [
    "https://nix-gaming.cachix.org"
    "https://mirrors.sjtu.edu.cn/nix-channels/store"
  ];
  nix.settings.extra-substituters = [
    "https://nix-community.cachix.org"
    # "https://hyprland.cachix.org"
    "https://anyrun.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
  ];
  nix.settings.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
