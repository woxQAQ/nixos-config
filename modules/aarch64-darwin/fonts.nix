{ pkgs, ... }:
{
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleFontSmoothing = 1;
      };
    };
  };
  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome

      inter
      noto-fonts-color-emoji
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      source-sans
      source-serif
      source-han-sans
      source-han-serif
      source-han-mono

      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      ioskeley-mono.term-nf
      maple-mono.NF-CN-unhinted

      lxgw-wenkai-screen
      literata
      resource-han-rounded
      yozai-font
      chillroundf
    ];
  };
}
