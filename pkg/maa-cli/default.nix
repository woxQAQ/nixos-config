{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  pkg-config,
  openssl,
  maa-assistant-arknights,
  android-tools,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maa-cli";
  # Pinned to the newest release whose maa-sys bindings all exist in the
  # latest stable MaaCore: 0.7.3+ eagerly binds AsstAsyncAttachWindow, which
  # only exists on MAA's unreleased dev branch.
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ndCe46+Q8ljFAingAHWoPcsf6NgtHJmApLcUP//2igc=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pkg-config
  ];

  buildInputs = [ openssl ];

  # Skip the self/core installers: core and CLI both come from nix.
  # https://github.com/MaaAssistantArknights/maa-cli/pull/126
  buildNoDefaultFeatures = true;
  buildFeatures = [ "git2" ];

  cargoHash = "sha256-3fjh8ofu6DsI0VspNjT2oBCN/q6BB3Nz/4KKn4DQYaM=";

  # Tests write to the maa cache dir; the sandbox's default HOME is read-only.
  preCheck = ''
    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/cache"
  '';

  # This test clones a real repository; the build sandbox has no network.
  checkFlags = [
    "--skip"
    "installer::resource::git::tests::clone_and_update_custom_branch_with_each_git_implementation"
  ];

  # maa-cli only searches libMaaCore.so and resources next to its own binary
  # https://github.com/MaaAssistantArknights/maa-cli/issues/67
  postInstall = ''
    mkdir -p $out/share/maa-assistant-arknights/
    ln -s ${maa-assistant-arknights}/share/maa-assistant-arknights/* $out/share/maa-assistant-arknights/
    ln -s ${maa-assistant-arknights}/lib/* $out/share/maa-assistant-arknights/
    mv $out/bin/maa $out/share/maa-assistant-arknights/

    makeWrapper $out/share/maa-assistant-arknights/maa $out/bin/maa \
      --prefix PATH : ${
        lib.makeBinPath [
          android-tools
          git
        ]
      }
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) /* sh */ ''
    installShellCompletion --cmd maa \
      --bash <($out/bin/maa complete bash) \
      --fish <($out/bin/maa complete fish) \
      --zsh <($out/bin/maa complete zsh)

    mkdir -p manpage
    $out/bin/maa mangen --path manpage
    installManPage manpage/*
  '';

  meta = {
    description = "Simple CLI for MAA by Rust";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "maa";
  };
})
