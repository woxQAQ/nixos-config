{
  lib,
  stdenvNoCC,
  fetchurl,
  python3,
  inter,
}:

stdenvNoCC.mkDerivation {
  pname = "inter-noto-sans-sc";
  version = "1.0";

  # nixpkgs ships Noto's CFF collection; merging with Inter requires glyf
  # outlines, so use the matching upstream TrueType variable font directly.
  notoSource = fetchurl {
    url = "https://raw.githubusercontent.com/notofonts/noto-cjk/Sans2.004/Sans/Variable/TTF/NotoSansCJKsc-VF.ttf";
    hash = "sha256-mQyAfnnCVmKlqez3+XG66yvy6rmlWeXs8Vzf24Vh0h8=";
  };
  notoLicense = fetchurl {
    url = "https://raw.githubusercontent.com/notofonts/noto-cjk/Sans2.004/LICENSE";
    hash = "sha256-anP5VBwt50FYwOfPawpY73dPWngL8ZHy1+ycxT7+K/I=";
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: [ ps.fonttools ]))
  ];

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    PYTHONHASHSEED=0 python ${./merge.py} \
      ${inter}/share/fonts/truetype/InterVariable.ttf \
      "$notoSource" \
      fonts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -m444 -Dt "$out/share/fonts/truetype" fonts/*.ttf
    install -m444 -D ${inter.src}/LICENSE.txt \
      "$out/share/doc/inter-noto-sans-sc/Inter-LICENSE.txt"
    install -m444 -D "$notoLicense" \
      "$out/share/doc/inter-noto-sans-sc/Noto-LICENSE.txt"
    install -m444 -D fonts/COPYRIGHT.txt \
      "$out/share/doc/inter-noto-sans-sc/COPYRIGHT.txt"
    install -m444 -D ${./README.md} \
      "$out/share/doc/inter-noto-sans-sc/README.md"

    runHook postInstall
  '';

  meta = {
    description = "Inter and Noto Sans CJK SC merged into one UI font family";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
