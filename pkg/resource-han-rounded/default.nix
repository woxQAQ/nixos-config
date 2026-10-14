{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
}:

# Resource Han Rounded (思源圆体): rounded derivative of Source Han Sans.
# v0.990 is the last static-instance release; v1.910 is a CFF2 variable-font
# pre-release, so we package the CN subset of v0.990 for maximum app
# compatibility. The font itself is OFL-1.1; upstream's LICENSE.txt bundles
# the copyright notices with the license text, and OFL requires shipping it
# alongside redistributed copies.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "resource-han-rounded";
  version = "0.990";

  src = fetchurl {
    url = "https://github.com/CyanoHao/Resource-Han-Rounded/releases/download/v${finalAttrs.version}/RHR-CN-${finalAttrs.version}.7z";
    hash = "sha256-5wBfe0p6C4NS0yxKE1j/R1ZOtzvn/bLbANn3knVencc=";
  };

  licenseText = fetchurl {
    name = "resource-han-rounded-LICENSE.txt";
    url = "https://raw.githubusercontent.com/CyanoHao/Resource-Han-Rounded/v${finalAttrs.version}/LICENSE.txt";
    hash = "sha256-er5fSQeAzS/VpnUCuZPiRO+H1jH7e5gkTpgZ/1kNpK8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/truetype {} +
    install -m444 -D ${finalAttrs.licenseText} $out/share/doc/resource-han-rounded/LICENSE.txt

    runHook postInstall
  '';

  meta = {
    description = "Rounded font family derived from Source Han Sans (思源圆体, CN subset)";
    homepage = "https://github.com/CyanoHao/Resource-Han-Rounded";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
