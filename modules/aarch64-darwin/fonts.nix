{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      material-design-icons

      hack-font
      maple-mono.NF-CN

      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];
  };
}
