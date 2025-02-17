{
  ...
}:
{
  imports = [
    ./program
    ./wm
    ./neovim
    ./terminal
    ./waypaper.nix
    ./fcitx
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
