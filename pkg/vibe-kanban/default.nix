# Vibe Kanban package for NixOS
# Vibe-kanban npm wrapper that downloads pre-built binaries
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
}:

let
  # Fetch adm-zip dependency
  admZip = fetchurl {
    url = "https://registry.npmjs.org/adm-zip/-/adm-zip-0.5.16.tgz";
    hash = "sha256-plYe0H5PeCr5xt7ZQUtN/D7lwKg6mfL0ay5gX25izyM=";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "vibe-kanban";
  version = "0.0.143";

  src = fetchurl {
    url = "https://registry.npmjs.org/vibe-kanban/-/vibe-kanban-${version}.tgz";
    hash = "sha256-EEP949qpgM30+7eHTDoYfW4mFFXmur9nMNKUS7i9Nks=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
  ];

  unpackPhase = ''
    mkdir -p package
    tar -xzf $src -C package
    cd package/package
  '';

  buildPhase = ''
    # Setup adm-zip dependency manually
    mkdir -p node_modules
    tar -xzf ${admZip} -C node_modules
    # adm-zip extracts to package/ directory
    mv node_modules/package node_modules/adm-zip
  '';

  installPhase = ''
    mkdir -p $out/lib/node_modules/${pname}
    cp -R * $out/lib/node_modules/${pname}/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/vibe-kanban \
      --add-flags "$out/lib/node_modules/${pname}/bin/cli.js" \
      --prefix NODE_PATH : $out/lib/node_modules/${pname}/node_modules
  '';

  meta = with lib; {
    description = "Get 10X more out of Claude Code, Codex or any coding agent";
    homepage = "https://github.com/BloopAI/vibe-kanban";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "vibe-kanban";
    platforms = platforms.unix;
  };
}
