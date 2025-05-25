{pkgs, ...}: {
  imports = [
    ./hyprland
    ./waypaper.nix
    ./gtk.nix
    ./browsers
    ./pot.nix
    ./game.nix
    ./ide.nix
    ./qt.nix
    ./xdg.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    mihomo-party
  ];
}
