{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome

      noto-fonts-color-emoji
      noto-fonts
      maple-mono.NF-CN
      maple-mono.NF-CN-unhinted

      source-sans
      source-serif
      source-han-sans
      source-han-serif
      source-han-mono

      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack

      lxgw-wenkai-screen
    ];
  };
}
