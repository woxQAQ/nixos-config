{ ... }:
{
  imports = [
    ./kitty.nix
    ./foot.nix
    ./alacritty.nix
    ./ghostty.nix
  ];
  programs.bash.enable = true;
}
