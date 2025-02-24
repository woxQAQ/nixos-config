{ ... }:
{
  imports = [
    ./cursor.nix
    ./chromium
    ./nix
    ./dev

    ./common.nix
    ./game.nix
    # ./rofi.nix
    ./cloud-native.nix
    ./ide.nix
    ./xdg.nix
    ./qt.nix
    ./gtk.nix
    ./git.nix
  ];
}
