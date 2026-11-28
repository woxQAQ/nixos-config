{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  buildGo127Module,
  bun,
  nodejs,
  cacert,
  git,
  patchelf,
  version,
}:
let
  src = fetchFromGitHub {
    owner = "NeuveAI";
    repo = "neuve";
    tag = "v${version}";
    hash = "sha256-EOuFTrSsud9qORTUCpVs3Z5s+BQnEFWngInbwBgsmWg=";
  };
  # Matches the release's apps/neuve-graph submodule pin.
  graphRevision = "bd99ee8f2a84d1cf0ac95f5e770ac368c0f2a576";
  graph = buildGo127Module {
    pname = "neuve-graph";
    version = graphRevision;
    src = fetchFromGitHub {
      owner = "NeuveAI";
      repo = "neuve-graph";
      rev = graphRevision;
      hash = "sha256-z7xTxmKhMmudgZvjwKiRrR+ujDGpSgwhq2wlcsyoxpM=";
    };
    # go mod vendor omits the tree_sitter/ header directories the PHP and SQL
    # grammars include, so the module cache is mirrored instead.
    proxyVendor = true;
    vendorHash = "sha256-bWD7sC/GLR+6OqiJAnrgetvLjvXP1opy5FIILGwCduk=";
    subPackages = [ "cmd/entire-graph" ];
    env.CGO_ENABLED = "1";
    # buildGoModule lists GOPROXY in impureEnvVars, so a builder's mirror (e.g.
    # a daemon-wide goproxy.cn) overrides env and yields a different set of
    # re-packaged zips for the same module graph. Pin it in the phase to keep
    # vendorHash reproducible across builders.
    modBuildPhase = ''
      runHook preBuild
      if [ -d vendor ]; then
        echo "vendor folder exists, please set 'vendorHash = null;' in your expression"
        exit 10
      fi
      export GIT_SSL_CAINFO=$NIX_SSL_CERT_FILE
      export GOPROXY='https://proxy.golang.org'
      mkdir -p "$GOPATH/pkg/mod/cache/download"
      go mod download
      mkdir -p vendor
      runHook postBuild
    '';
    doCheck = false;
  };
  nodeModules = stdenvNoCC.mkDerivation {
    pname = "neuve-node-modules";
    inherit version src;
    nativeBuildInputs = [
      bun
      cacert
      git
    ];
    dontConfigure = true;
    dontFixup = true;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    buildPhase = ''
      runHook preBuild
      export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
      bun install --frozen-lockfile --ignore-scripts --no-progress
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      find . -type d -name node_modules -prune -exec cp -R --parents '{}' "$out" ';'
      runHook postInstall
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-qcCrNo9wojcgVcBDyaQ8h7hNchqs/W1sbgMUp3BGzEc=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "neuve";
  inherit version src;
  nativeBuildInputs = [
    bun
    nodejs
    patchelf
    git
  ];
  dontConfigure = true;
  # The install manifest hashes the final files, including the ELF interpreter.
  dontFixup = true;

  buildPhase = ''
    runHook preBuild
    # The desk rejects references to its temporary directory; /build is also
    # a legitimate URL fragment in bundled dependencies, so use a private root.
    mkdir -p "$TMPDIR/neuve-build"
    export TMPDIR="$TMPDIR/neuve-build"
    cp -R ${nodeModules}/. .
    chmod -R u+w .
    patchShebangs node_modules
    export PATH="$PWD/node_modules/.bin:$PATH"
    bun apps/neuve-cli/scripts/build.ts --outfile "$TMPDIR/neuve" --version ${version}
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$TMPDIR/neuve"
    bun apps/neuve-cli/scripts/build-desk.ts --out "$TMPDIR/desk" --version ${version}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp ${./install-linux.ts} ./install-nix.ts
    bun ./install-nix.ts "$out" "$TMPDIR/neuve" ${graph}/bin/entire-graph "$TMPDIR/desk" ${version} ${graphRevision}
    install -Dm644 LICENSE "$out/share/neuve/notices/LICENSE"
    install -Dm644 ${graph.src}/LICENSE "$out/share/neuve/notices/neuve-graph/LICENSE"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$("$out/bin/neuve" --version)" = "neuve ${version}"
    "$out/lib/neuve/entire-graph" version
    "$out/bin/neuve" --help > /dev/null

    smoke="$TMPDIR/neuve-smoke"
    mkdir -p "$smoke/home"
    git init -q "$smoke/repo"
    git -C "$smoke/repo" -c user.name=Fixture -c user.email=fixture@example.invalid \
      commit --allow-empty -qm 'Initial fixture'
    env HOME="$smoke/home" "$out/bin/neuve" setup \
      --repo "$smoke/repo" --route anthropic --no-skills
    env HOME="$smoke/home" "$out/bin/neuve" setup hooks \
      --repo "$smoke/repo" --agents none --no-stack --command "$out/bin/neuve"
    test -f "$smoke/repo/.git/neuve/setup/config.json"
    test -f "$smoke/repo/.git/neuve/capture.json"
    test -z "$(git -C "$smoke/repo" status --porcelain)"
    runHook postInstallCheck
  '';

  passthru = { inherit graph nodeModules; };
  meta = {
    description = "Local code review tool with agentic, graph and semantic analysis";
    homepage = "https://github.com/NeuveAI/neuve";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "neuve";
  };
}
