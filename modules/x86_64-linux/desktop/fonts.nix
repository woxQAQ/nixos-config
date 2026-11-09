{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-icons
      material-design-icons
      font-awesome

      # normal fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
      noto-fonts-cjk-serif

      source-sans
      source-serif
      source-han-sans
      source-han-serif

      # nerdfonts
      nerd-fonts.symbols-only
      nerd-fonts.hack
      maple-mono.NF-CN
      ioskeley-chillround

      b612
      comic-neue
      lxgw-wenkai-screen
      inter-noto-sans-sc
      chillroundf
    ];
    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;
    fontDir.enable = true;
    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojisthat would sometimes show instead of some Color emojis
    fontconfig = {
      defaultFonts = {
        serif = [
          "Source Serif 4"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
        ];
        sansSerif = [
          "Inter Noto Sans SC"
          "Noto Sans TC"
          # "Source Sans 3"
        ];
        monospace = [
          "Ioskeley ChillRound Mono"
          "Material Design Icons"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      # Use grayscale antialiasing across displays with different scale factors.
      # Physical RGB/BGR subpixel layouts have not been verified.
      subpixel.rgba = "rgb";
      hinting = {
        enable = false;
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
      font-name = "Ioskeley ChillRound Mono";
      font-size = 14;
      # Whether to use 3D hardware acceleration to render the console.
      hwaccel = true;
    };
    extraOptions = "--term xterm-256color";
  };
}
