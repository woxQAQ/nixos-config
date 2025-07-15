{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      material-design-icons

      hack-font
      maple-mono.NF
      maple-mono.NF-CN
      maple-mono.CN

      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
    ];
  };
}
