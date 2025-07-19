{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # normal fonts
      noto-fonts
      sarasa-gothic
      noto-fonts-cjk-sans
      noto-fonts-emoji

      source-sans
      source-serif
      source-han-sans
      source-han-serif
      source-han-mono

      maple-mono.NF-CN-unhinted

      # nerdfonts
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.iosevka

      lxgw-wenkai-screen
    ];
    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;
    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig = {
      defaultFonts = {
        serif = [
          "Source Sans 3"
          "Source Han Serif SC"
          "Source Han Serif TC"
        ];
        sansSerif = [
          "Source Serif 4"
          "LXGW WenKai Screen"
          "Source Han Sans SC"
          "Source Han Sans TC"
        ];
        monospace = [
          "Maple Mono NF CN"
          "Source Han Mono SC"
          "Source Han Mono TC"
          # "JetBrainsMono Nerd Font"
          "JetBrains Nerd Font"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      subpixel.rgba = "rgb";
      hinting.enable = false;
      antialias = true;
    };

  };
  services.kmscon = with pkgs; {
    # Use kmscon as the virtual console instead of gettys.
    # kmscon is a kms/dri-based userspace virtual terminal implementation.
    # It supports a richer feature set than the standard linux console VT,
    # including full unicode support, and when the video card supports drm should be much faster.
    enable = true;
    fonts = [
      {
        name = "Maple Mono NF CN";
        package = maple-mono.NF-CN-unhinted;
      }
      {
        name = "JetBrainsMono Nerd Font";
        package = nerd-fonts.jetbrains-mono;
      }
    ];
    extraOptions = "--term xterm-256color";
    extraConfig = "font-size=12";
    # Whether to use 3D hardware acceleration to render the console.
    hwRender = true;
  };
}
