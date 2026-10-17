{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chillroundf";
  version = "3.200";

  src = fetchurl {
    url = "https://github.com/Warren2060/ChillRound/releases/download/v${finalAttrs.version}/ChillRoundF_v${finalAttrs.version}.zip";
    hash = "sha256-egYeOcyPN3zhIvCuaNH+PvQ9eEMTiDYsYeqNaVci0mc=";
  };

  sourceRoot = "ChillRoundF_v${finalAttrs.version}";

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install only TTFs to avoid duplicate faces from the bundled OTFs.
    install -m444 -Dt "$out/share/fonts/truetype" ./*.ttf
    install -m444 -D LICENSE.txt "$out/share/doc/chillroundf/LICENSE.txt"

    runHook postInstall
  '';

  meta = {
    description = "Chinese rounded font family with regular and bold weights (寒蝉全圆体)";
    homepage = "https://github.com/Warren2060/ChillRound";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
