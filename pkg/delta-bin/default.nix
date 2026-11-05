{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  patchelf,
  desktop-file-utils,
  glibc,
  vulkan-loader,
  libglvnd,
  wayland,
  libxkbcommon,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxcursor,
  libxrandr,
  libxi,
  libxext,
  libxrender,
  libxfixes,
  fontconfig,
  freetype,
  openssl,
  zlib,
  alsa-lib,
}:
let
  hashes = {
    x86_64-linux = "sha256-nWmR0N0HG/mvxmLCGInfBqdFWZ678CqNUSq0EIkE71o=";
    aarch64-linux = "sha256-hAlrlULIGkt7uBITDT2zktrCgGuhxP+MyeopC3jTVEg=";
  };
  runtimeLibraryPath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    vulkan-loader
    libglvnd
    wayland
    libxkbcommon
    libx11
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    libxcursor
    libxrandr
    libxi
    libxext
    libxrender
    libxfixes
    fontconfig
    freetype
    openssl
    zlib
    alsa-lib
  ];
in
# Adapted from https://github.com/zed-industries/delta-nix.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "delta-bin";
  version = "0.24.0";

  src = fetchurl {
    url = "https://github.com/zed-industries/delta-nix/releases/download/v${finalAttrs.version}/delta-linux-${stdenvNoCC.hostPlatform.parsed.cpu.name}.tar.gz";
    hash = hashes.${stdenvNoCC.hostPlatform.system};
  };

  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  # Generic fixup would shrink RPATHs needed by dynamically loaded libraries.
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    appDir="$out/opt/delta"
    mkdir -p "$appDir" "$out/bin" "$out/share/applications"
    cp -a . "$appDir/"
    chmod -R u+w "$appDir"

    # Use Nix's libxkbcommon, which embeds the matching xkeyboard-config path.
    rm "$appDir/lib/libxkbcommon.so.0" "$appDir/lib/libxkbcommon-x11.so.0"

    rpath="$appDir/lib:${runtimeLibraryPath}:\$ORIGIN/../lib:\$ORIGIN"
    find "$appDir" -type f \( -perm -0100 -o -name '*.so' -o -name '*.so.*' \) -print0 |
    while IFS= read -r -d "" elf; do
      if patchelf --print-rpath "$elf" >/dev/null 2>&1; then
        patchelf --set-rpath "$rpath" "$elf"
        if patchelf --print-interpreter "$elf" >/dev/null 2>&1; then
          patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" "$elf"
        fi
      fi
    done

    # LD_LIBRARY_PATH also covers transitive dlopen calls, including GPU drivers.
    for program in delta delta-app; do
      commandName="$program"
      if [ "$program" = delta ]; then
        # Reserve the public delta command for the Git diff viewer.
        commandName=delta-ai
      fi
      makeWrapper "$appDir/bin/$program" "$out/bin/$commandName" \
        --prefix LD_LIBRARY_PATH : "$appDir/lib:${runtimeLibraryPath}" \
        --set DELTA_UPDATE_EXPLANATION \
          "Delta is managed by Nix; update pkg/delta-bin to install a newer release."
    done

    cp -a "$appDir/share/icons" "$out/share/icons"
    for desktopFile in "$appDir"/share/applications/*.desktop; do
      substitute "$desktopFile" "$out/share/applications/$(basename "$desktopFile")" \
        --replace-fail "Exec=delta " "Exec=$out/bin/delta-ai "
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ desktop-file-utils ];
  installCheckPhase = ''
    runHook preInstallCheck

    desktop-file-validate "$out/share/applications/"*.desktop
    for program in delta-ai delta-app; do
      grep -F "DELTA_UPDATE_EXPLANATION" "$out/bin/$program"
    done
    grep -Fx "Exec=$out/bin/delta-ai open %U" "$out/share/applications/dev.zed.Delta.desktop"

    find "$out/opt/delta" -type f \( -perm -0100 -o -name '*.so' -o -name '*.so.*' \) -print0 |
    while IFS= read -r -d "" elf; do
      if patchelf --print-rpath "$elf" >/dev/null 2>&1; then
        ${glibc.bin}/bin/ldd "$elf"
      fi
    done | tee ldd.log
    if grep -q 'not found' ldd.log; then
      echo "unresolved shared-library dependencies remain" >&2
      exit 1
    fi
    grep -F "${lib.getLib libxkbcommon}/lib/libxkbcommon.so.0" ldd.log
    grep -F "${lib.getLib libxkbcommon}/lib/libxkbcommon-x11.so.0" ldd.log

    runHook postInstallCheck
  '';

  meta = {
    description = "Delta, the AI coding assistant";
    homepage = "https://delta.dev";
    changelog = "https://github.com/zed-industries/delta-nix/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames hashes;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "delta-ai";
  };
})
