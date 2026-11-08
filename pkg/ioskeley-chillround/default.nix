{
  lib,
  stdenvNoCC,
  python3,
  ioskeley-mono,
  chillroundf,
}:

stdenvNoCC.mkDerivation {
  pname = "ioskeley-chillround";
  version = "1.0";

  nativeBuildInputs = [ (python3.withPackages (ps: [ ps.fonttools ])) ];
  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    PYTHONHASHSEED=0 python ${./merge.py} \
      ${ioskeley-mono.term-nf}/share/fonts/truetype \
      ${chillroundf}/share/fonts/truetype fonts
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -m444 -Dt "$out/share/fonts/truetype" fonts/*.ttf
    mkdir -p "$out/share/doc/ioskeley-chillround"
    install -m444 ${chillroundf}/share/doc/chillroundf/LICENSE.txt \
      "$out/share/doc/ioskeley-chillround/OFL.txt"
    install -m444 fonts/COPYRIGHT.txt ${./README.md} "$out/share/doc/ioskeley-chillround/"
    runHook postInstall
  '';

  meta = {
    description = "Ioskeley terminal font with ChillRoundF Chinese glyphs and Nerd Font icons";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
