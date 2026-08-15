{ pkgs, ... }:
let
  # The upstream IoskeleyMono Nerd Font release ships with post.isFixedPitch=0,
  # so CoreText does not classify it as monospaced and kitty refuses to use it
  # (falls back to Menlo). Patch the flag with fontTools.
  fix-is-fixed-pitch = pkgs.writeText "fix-is-fixed-pitch.py" ''
    import sys

    from fontTools.ttLib import TTFont

    for path in sys.argv[1:]:
        font = TTFont(path)
        font["post"].isFixedPitch = 1
        font.save(path)
  '';
  fonttools-python = pkgs.python3.withPackages (ps: [ ps.fonttools ]);
  ioskeley-mono-normal-NF = pkgs.ioskeley-mono.normal-NF.overrideAttrs (oldAttrs: {
    # fonts are installed by the installFonts preInstall hook
    postInstall = (oldAttrs.postInstall or "") + ''
      ${fonttools-python}/bin/python ${fix-is-fixed-pitch} $out/share/fonts/truetype/*.ttf
    '';
  });
in
{
  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome

      noto-fonts-color-emoji
      noto-fonts
      noto-fonts-cjk-sans

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
      ioskeley-mono-normal-NF

      lxgw-wenkai-screen
    ];
  };
}
