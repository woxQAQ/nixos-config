{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
let
  arch = stdenvNoCC.hostPlatform.parsed.cpu.name;
  hashes = {
    aarch64 = "sha256-xCexm7DVX1vZk5GyHnvaDc+JKr2A28Ag72RcnYZFeUA=";
    x86_64 = "sha256-A9ghNqaOE+2+PmJEM94orwwlyoa5412rJ2N5vVIVGcw=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zed-editor-bin";
  version = "1.25.2";

  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v${finalAttrs.version}/Zed-${arch}.dmg";
    hash = hashes.${arch};
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = ".";
  dontBuild = true;

  # Keep the upstream-signed app bundle intact.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R Zed.app "$out/Applications/"
    # The CLI locates Zed.app from its own executable path.
    ln -s "$out/Applications/Zed.app/Contents/MacOS/cli" "$out/bin/zed"
    # Keep the command name used by nixpkgs and Home Manager.
    ln -s zed "$out/bin/zeditor"

    runHook postInstall
  '';

  meta = {
    description = "Zed editor, repackaged from the official macOS release";
    homepage = "https://zed.dev";
    changelog = "https://github.com/zed-industries/zed/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "zeditor";
  };
})
