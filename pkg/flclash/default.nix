{
  lib,
  fetchFromGitHub,
  flutter350,
  glib,
  gtk3,
  keybinder3,
  libayatana-appindicator,
  pkg-config,
  buildGoModule,
  go_1_27,
  runCommand,
  rustPlatform,
  writeShellScriptBin,
  cargo,
  rustc,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
}:

let
  pname = "flclash";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "chen08209";
    repo = "FlClash";
    tag = "v${version}";
    preFetch = ''
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
    hash = "sha256-SkefPGfdxB04wHcBg/Dg4ZZkvLjJb/LHzxtRe9u2reA=";
    fetchSubmodules = true;
  };

  # The in-tree plugins (wifi_ssid, tray, ...) declare SwiftPM-only darwin
  # entries, and flutter_tools aborts plugin injection for them even when
  # building for linux. Path dependencies are resolved from the source tree
  # itself (not the build directory), so postPatch cannot fix this; patch
  # the source instead. Only linux is built here, so dropping the ios/macos
  # entries from the plugin pubspecs is safe.
  srcPatched = runCommand "flclash-${version}-src-patched" { } ''
    cp -r ${src} $out
    chmod -R u+w $out
    for f in "$out"/plugins/*/pubspec.yaml; do
      awk '
        /^      (ios|macos):/ { skip = 1; next }
        skip && /^ {0,6}[^ ]/ { skip = 0 }
        !skip { print }
      ' "$f" > "$f.tmp"
      mv "$f.tmp" "$f"
    done

    # The setup hook builds the Core/Helper itself; nix builds them instead.
    sed -i '/^    setup:$/,/build_assets/ s/build_assets: true/build_assets: false/' \
      $out/pubspec.yaml

    # `final` on named parameters exceeds the package's language version
    # (pubspec sdk floor is 3.10); drop the modifier.
    sed -i 's/final VoidCallback? onPressed,/VoidCallback? onPressed,/' \
      $out/lib/views/profiles/custom/groups.dart \
      $out/lib/views/profiles/custom/rules.dart
  '';

  meta = {
    description = "Proxy client based on ClashMeta, simple and easy to use";
    homepage = "https://github.com/chen08209/FlClash";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
  };

  # Vendored crates for the rust_api plugin's native-assets build hook.
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    cargoRoot = "plugins/rust_api/rust";
    hash = "sha256-DKMzkfDt2CJYqaxcm635seFJydKNNdtC69o2b2bWWUY=";
  };

  # Upstream's setup build hook also builds FlClashHelperService: a Rust
  # binary that embeds the Core's sha256 to verify it at runtime.
  helperCargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    cargoRoot = "services/helper";
    hash = "sha256-M7m+rs96S4CkQK/mnJ+5IcHXQKMl3Yp2bovdpwc+Nn4=";
  };

  helper = rustPlatform.buildRustPackage {
    pname = "flclash-helper";
    inherit version src meta;

    sourceRoot = "source/services/helper";

    cargoDeps = helperCargoDeps;

    env.CORE_NAME = "FlClashCore";

    preBuild = ''
      export CORE_SHA256="$(sha256sum ${core}/bin/FlClashCore | cut -d ' ' -f 1)"
    '';

    postInstall = ''
      mv $out/bin/helper $out/bin/FlClashHelperService
    '';

    doCheck = false;
  };

  # native_toolchain_rust drives cargo exclusively through rustup. The shim
  # forwards `rustup run <channel> <cmd>` to the nix-provided toolchain.
  rustupShim = writeShellScriptBin "rustup" ''
    case "$1" in
      show)
        echo "1.99.0-x86_64-unknown-linux-gnu (default)"
        ;;
      run)
        shift 2
        exec "$@"
        ;;
      *)
        echo "rustup shim: unsupported command: $*" >&2
        exit 1
        ;;
    esac
  '';

  # Core requires go >= 1.27 while pinned nixpkgs defaults to go 1.26.
  core = (buildGoModule.override { go = go_1_27; }) {
    pname = "core";
    inherit version src meta;

    modRoot = "core";

    vendorHash = "sha256-FeSLlJ70KSiWFoZ61yyj9BoZTPHdv7lnwPBEnCmNElg=";

    env.CGO_ENABLED = 0;

    buildPhase = ''
      runHook preBuild

      mkdir -p $out/bin
      go build -ldflags="-w -s" -tags=with_gvisor -o $out/bin/FlClashCore ./cmd/core

      runHook postBuild
    '';
  };
in
flutter350.buildFlutterApplication {
  inherit pname version;
  src = srcPatched;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  # The sqlcipher_flutter_libs 0.7.0+eol / sqlite3_flutter_libs 0.6.0+eol
  # stubs on pub.dev ship only Dart sources without linux/CMakeLists.txt,
  # which the nixpkgs source builders expect to patch. Nothing native to
  # build — pass through.
  customSourceBuilders = {
    sqlcipher_flutter_libs = { src, ... }: src;
    sqlite3_flutter_libs = { src, ... }: src;
  };

  gitHashes = lib.importJSON ./git-hashes.json;

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    # For the rust_api plugin's native-assets build hook.
    cargo
    rustc
    rustupShim
    # rust_api 0.9.4 links glib/gtk via *-sys crates whose build scripts
    # probe pkg-config.
    pkg-config
  ];

  buildInputs = [
    glib
    gtk3
    keybinder3
    libayatana-appindicator
  ];

  flutterBuildFlags = [ "--dart-define=APP_ENV=stable" ];

  # Flutter 3.50 keeps the Wayland subsurface's initial buffer scale when the
  # window changes monitors. Prefer XWayland until flutter/flutter#196476 is fixed.
  extraWrapProgramArgs = "--set GDK_BACKEND x11,wayland";

  desktopItems = [
    (makeDesktopItem {
      name = "flclash";
      exec = "FlClash %U";
      icon = "flclash";
      genericName = "FlClash";
      desktopName = "FlClash";
      categories = [ "Network" ];
      keywords = [
        "FlClash"
        "Clash"
        "ClashMeta"
        "Proxy"
      ];
    })
  ];

  preBuild = ''
    mkdir -p libclash/linux
    cp ${core}/bin/FlClashCore libclash/linux/FlClashCore
    cp ${helper}/bin/FlClashHelperService libclash/linux/FlClashHelperService
    printf '{"coreSha256":"%s"}\n' \
      "$(sha256sum ${core}/bin/FlClashCore | cut -d ' ' -f 1)" \
      > libclash/linux/manifest.json

    # Offline cargo setup for the rust_api native-assets hook.
    # hooks_runner (pinned by flutter_tools) spawns hooks with a whitelist
    # environment that drops PKG_CONFIG_PATH, so inject it through cargo's
    # [env] table instead; $HOME survives the whitelist.
    mkdir -p "$HOME/.cargo"
    cat > "$HOME/.cargo/config.toml" <<EOF
    [source.crates-io]
    replace-with = "vendored-sources"
    [source.vendored-sources]
    directory = "${cargoDeps}/source-registry-0"
    [env]
    PKG_CONFIG_PATH = { value = "$PKG_CONFIG_PATH", force = true }
    EOF
    export CARGO_NET_OFFLINE=true
  '';

  postInstall = ''
    install -D --mode=0644 assets/images/icon.png $out/share/pixmaps/flclash.png

    # The generic installPhase symlinks every top-level bundle file into
    # bin/, and dartFixupHook refuses to wrap non-executables.
    rm -f $out/bin/manifest.json
  '';

  # Dart ffi dlopen (flutter_rust_bridge) resolves librust_api.so through
  # the RUNPATH of the calling object, which is the engine library, not the
  # main executable. Let it find the bundle's own lib directory. Appended
  # via postFixupHooks so it runs after autoPatchelfHook, which registers
  # itself on the same array and rewrites the RPATH.
  preFixup = ''
    addBundleOriginRpath() {
      patchelf --add-rpath '$ORIGIN' $out/app/flclash/lib/libflutter_linux_gtk.so
      patchelf --add-rpath '$ORIGIN' $out/app/flclash/lib/libapp.so
    }
    postFixupHooks+=(addBundleOriginRpath)
  '';

  passthru = {
    inherit
      core
      cargoDeps
      helper
      helperCargoDeps
      ;
  };

  meta = meta // {
    mainProgram = "FlClash";
    platforms = lib.platforms.linux;
  };
}
