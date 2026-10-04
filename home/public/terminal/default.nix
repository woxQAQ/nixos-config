{ ... }:
{
  imports = [
    ./kitty.nix
    ./alacritty.nix
    ./ghostty.nix
  ];
  programs.bash.enable = true;
}
