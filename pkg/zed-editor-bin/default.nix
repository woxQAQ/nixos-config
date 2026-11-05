{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
let
  arch = stdenvNoCC.hostPlatform.parsed.cpu.name;
  hashes = {
    aarch64 = "sha256-jc/fqpSRfOzg/1Krbj9xF8Zke3jzLSZmhM8ME0Ytdqg=";
    x86_64 = "sha256-eomp1AQBAEMp7EDvDxiO5VNuY4kGsf9uW/x57afJlbM=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zed-editor-bin";
  version = "1.27.0";

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
