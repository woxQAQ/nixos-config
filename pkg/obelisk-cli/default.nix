{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "obelisk";
  version = "0.3.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@obelisk-apps/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-q8cUIgo9heXO6nQh9prmYZDCPV2FhL+rJm52HklBGRY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/obelisk
    cp -R dist package.json $out/lib/obelisk/

    makeWrapper ${nodejs}/bin/node $out/bin/obelisk \
      --add-flags $out/lib/obelisk/dist/cli/src/obelisk.js

    runHook postInstall
  '';

  meta = {
    description = "Local runtime for querying coding-agent session history";
    homepage = "https://github.com/tommy0103/obelisk";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "obelisk";
  };
})
