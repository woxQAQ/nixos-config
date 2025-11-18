{ ... }:
{
  imports = [
    ./kitty.nix
    ./foot.nix
    ./alacritty.nix
  ];
  programs.bash.enable = true;
}
