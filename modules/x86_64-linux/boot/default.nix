{ pkgs, ... }:
{
  boot = {
    consoleLogLevel = 3;
    loader = {
      grub = {
        enable = true;
        # device = "nodev";
        efiSupport = true;
        gfxmodeEfi = "2715x1527"; # for 4k: 3840x2160
        gfxmodeBios = "2715x1527"; # for 4k: 3840x2160
        theme =
          let
            theme-path = "src/catppuccin-mocha-grub-theme";
            font-path = "${pkgs.spleen}/share/fonts/misc/spleen-16x32.otf";
          in
          pkgs.stdenv.mkDerivation rec {
            pname = "catppuccin-mocha-grub";
            version = "1.0.0";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "grub";
              rev = "v${version}";
              hash = "sha256-/bSolCta8GCZ4lP0u5NVqYQ9Y3ZooYCNdTwORNvR7M0=";
            };
            nativeBuildInputs = with pkgs; [
              grub2
              spleen
            ];
            prePatch = ''
              substituteInPlace ${theme-path}/theme.txt \
                --replace "Unifont Regular 16" "Spleen 16x32 Regular 32" \
            '';
            buildPhase = ''
              grub-mkfont --size 32 ${font-path} -o ${theme-path}/font.pf2
            '';
            installPhase = ''
              cp -r ${theme-path} $out
            '';
          };
      };
    };
    tmp.cleanOnBoot = true;
  };
}
