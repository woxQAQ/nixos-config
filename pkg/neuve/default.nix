{
  lib,
  stdenvNoCC,
  fetchurl,
  callPackage,
}:
let
  version = "0.2.1";
in
if stdenvNoCC.hostPlatform.isLinux then
  callPackage ./linux.nix { inherit version; }
else
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "neuve";
    inherit version;

    src = fetchurl {
      url = "https://github.com/NeuveAI/neuve/releases/download/v${finalAttrs.version}/neuve-darwin-arm64.tar.gz";
      hash = "sha256-3RWhvTDYUIOKm+doEoRi479oayh4aoFXdRsyjh7O8cE=";
    };

    dontConfigure = true;
    dontBuild = true;
    # The install receipt records payload hashes; preserve the signed binaries
    # and semantic workers exactly as shipped.
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R bin lib share "$out/"
      substitute "$out/lib/neuve/install.json.in" "$out/lib/neuve/install.json" \
        --replace-fail '@NEUVE_PREFIX@' "$out" \
        --replace-fail '@NEUVE_INSTALLED_AT@' '1970-01-01T00:00:01Z'
      rm "$out/lib/neuve/install.json.in"

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test "$("$out/bin/neuve" --version)" = "neuve ${finalAttrs.version}"
      "$out/lib/neuve/entire-graph" version
      "$out/bin/neuve" --help > /dev/null

      runHook postInstallCheck
    '';

    meta = {
      description = "Local code review tool with agentic, graph and semantic analysis";
      homepage = "https://github.com/NeuveAI/neuve";
      license = lib.licenses.mit;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "aarch64-darwin" ];
      mainProgram = "neuve";
    };
  })
