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
      noto-fonts-color-emoji

      source-sans
      source-serif
      source-han-sans
      source-han-serif
      source-han-mono

      maple-mono.NF-CN

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
          "Source Serif 4"
          "Source Han Serif SC"
          "Source Han Serif TC"
        ];
        sansSerif = [
          "Source Sans 3"
          "Source Han Sans SC"
          "Source Han Sans TC"
          "LXGW WenKai Screen"
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
      subpixel.rgba = "none";
      hinting = {
        enable = true;
        style = "slight";
      };
      antialias = true;
    };

  };
  services.kmscon = {
    # Use kmscon as the virtual console instead of gettys.
    # kmscon is a kms/dri-based userspace virtual terminal implementation.
    # It supports a richer feature set than the standard linux console VT,
    # including full unicode support, and when the video card supports drm should be much faster.
    enable = true;
    config = {
      font-name = "Maple Mono NF CN";
      font-size = 14;
      # Whether to use 3D hardware acceleration to render the console.
      hwaccel = true;
    };
    extraOptions = "--term xterm-256color";
  };
}
