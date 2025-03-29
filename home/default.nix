{
  inputs,
  username,
  stateVersion,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./program
    ./wm
    ../neovim
    ./fcitx
    ./public
  ];
  home = {
    inherit username stateVersion;
    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
