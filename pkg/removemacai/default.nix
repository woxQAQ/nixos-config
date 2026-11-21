{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "removemacai";
  version = "1.2.2";

  src = fetchurl {
    url = "https://github.com/omlahore/RemoveMacAI/releases/download/v${finalAttrs.version}/RemoveMacAI.zip";
    hash = "sha256-Mgv+PFuNqzrOCC/6W+PiQtEaVtkhhpkhkhFlHmBfm5A=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";
  dontBuild = true;

  # Preserve the app bundle's upstream ad-hoc signature.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R RemoveMacAI.app "$out/Applications/"

    runHook postInstall
  '';

  meta = {
    description = "Debloat macOS and disable Apple Intelligence";
    homepage = "https://github.com/omlahore/RemoveMacAI";
    changelog = "https://github.com/omlahore/RemoveMacAI/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
