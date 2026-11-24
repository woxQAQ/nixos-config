{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:
let
  # Companion skill teaching agents to query session history through this CLI.
  skill = fetchFromGitHub {
    owner = "tommy0103";
    repo = "obelisk-skill";
    rev = "506c221788d5377c08a297998f62e1783319a121";
    hash = "sha256-J5Pl8/ZFxbUODDRMNUyqpLgs32gGJcfW9i+sXnuX+5Y=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "obelisk";
  version = "0.3.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@obelisk-apps/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-W0xh6gjCFIJ6hwGTP4MeP+VRgwNi6NbJZ9HcXUFg0qk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  # Upstream ships no Grok CLI / Delta IDE providers. We inject ours into the
  # unpacked dist tree and register them in the builtin provider registry.
  patches = [ ./register-providers.patch ];

  postPatch = ''
    cp ${./providers/grok.js} dist/core/src/providers/grok.js
    cp ${./providers/delta.js} dist/core/src/providers/delta.js
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/obelisk
    cp -R dist package.json $out/lib/obelisk/

    makeWrapper ${nodejs}/bin/node $out/bin/obelisk \
      --add-flags $out/lib/obelisk/dist/cli/src/obelisk.js

    mkdir -p $out/share/skills
    cp -R ${skill}/skills/. $out/share/skills/

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
