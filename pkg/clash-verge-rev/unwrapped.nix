{
  pname,
  version,
  src,
  meta,

  pnpm-hash,
  rustPlatform,

  cargo-tauri,
  jq,
  moreutils,
  nodejs,
  pkg-config,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,

  libayatana-appindicator,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
}:
rustPlatform.buildRustPackage {
  inherit version src meta;
  pname = "${pname}-unwrapped";

  cargoLock = {
    lockFileContents =
      builtins.replaceStrings
        [
          ''"tao-macros 0.1.3 (registry+https://github.com/rust-lang/crates.io-index)",''
          ''
            [[package]]
            name = "tao-macros"
            version = "0.1.3"
            source = "registry+https://github.com/rust-lang/crates.io-index"
            checksum = "f4e16beb8b2ac17db28eab8bca40e62dbfbb34c0fcdc6d9826b11b7b5d047dfd"
            dependencies = [
             "proc-macro2",
             "quote",
             "syn 2.0.114",
            ]

          ''
        ]
        [
          ''"tao-macros 0.1.3 (git+https://github.com/tauri-apps/tao)",''
          ""
        ]
        (builtins.readFile "${src}/Cargo.lock");

    outputHashes = {
      "clash_verge_logger-0.2.2" = "sha256-2EbXwlYwps6XRm1Crcr6koGWbF4ZRXJ6hUqq04YMARg=";
      "clash_verge_service_ipc-2.1.1" = "sha256-qU7baSJDro7TZT21lg8cbMj26hwZ8yx1iEgeSYAK9aY=";
      "dark-light-2.0.0" = "sha256-4JPfNSk8MsMMxJPz6M8ju+sMVXlAerct16xwbkEWpYw=";
      "sysproxy-0.4.3" = "sha256-Eb9iYgnGSg5X6gLmwezEXRGE4jrrJpFvOGZAkwns0YA=";
      "tao-0.34.5" = "sha256-oY7C1nEhb/vJf8q/sn6zQDlQKYP8zQQ15HrtEb9GEu8=";
      "tao-macros-0.1.3" = "sha256-oY7C1nEhb/vJf8q/sn6zQDlQKYP8zQQ15HrtEb9GEu8=";
      "tauri-plugin-mihomo-0.1.3" = "sha256-G/vkUdZs4ug3x8qE7sGU5duooo91yoV7amQ/5vlXTmU=";
    };
  };

  patches = [
    ./patches/tao-macros-git.patch
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      ;
    pnpm = pnpm_9;
    fetcherVersion = 1;
    hash = pnpm-hash;
  };

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  # patches = [
  #   (fetchpatch {
  #     url = "https://github.com/clash-verge-rev/clash-verge-rev/commit/645b92bc2815fe55bbc827907bff0edbfee48674.patch";
  #     hash = "sha256-BH0SvVofW6YJ3e/LOHojisenMwcxYfm3gG/dbxvYBMs=";
  #   })
  # ];

  postPatch = ''
    # We disable the option to try to use the bleeding-edge version of mihomo
    # If you need a newer version, you can override the mihomo input of the wrapped package
    sed -i -e '/Mihomo Alpha/d' ./src/components/setting/mods/clash-core-viewer.tsx

    # this file tries to override the linker used when compiling for certain platforms
    rm -f .cargo/config.toml

    # disable updater and don't try to bundle helper binaries
    jq '
      .bundle.createUpdaterArtifacts = false |
      del(.bundle.resources) |
      del(.bundle.externalBin)
    ' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json

    jq 'del(.bundle.externalBin)' src-tauri/tauri.linux.conf.json | sponge src-tauri/tauri.linux.conf.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    jq
    moreutils
    nodejs
    pkg-config
    pnpmConfigHook
    pnpm_9
  ];

  buildInputs = [
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  # make sure the .desktop file name does not contain whitespace,
  # so that the service can register it as an auto-start item
  postInstall = ''
    mv $out/share/applications/Clash\ Verge.desktop $out/share/applications/clash-verge.desktop
  '';
}
