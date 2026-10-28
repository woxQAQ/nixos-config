{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  wrapGAppsHook3,
  bun,
  desktop-file-utils,
  fontconfig,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  libsoup_3,
  libX11,
  wayland,
  webkitgtk_4_1,
  xdg-utils,
}:
let
  platform =
    {
      x86_64-linux = {
        arch = "amd64";
        hash = "sha256-cHTlOwstVaz8tpspzTN/SymPA8rziMTvYYAoMQDmwtg=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-ot7hU2gKNaN8eY7PVCtqCyxIcpEOwpWBFo5gRTelghE=";
      };
    }
    .${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magpie";
  version = "0.1.1862";

  src = fetchurl {
    url = "https://github.com/yetone/magpie/releases/download/v${finalAttrs.version}/magpie-linux-${platform.arch}";
    inherit (platform) hash;
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/yetone/magpie/v${finalAttrs.version}/build/icon/magpie.svg";
    hash = "sha256-fT50MnUFiN0JxQqsNMF2NWQExwhiJmb8WYPxFR4mv/U=";
  };

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/yetone/magpie/v${finalAttrs.version}/LICENSE";
    hash = "sha256-edLIREcV1LxFPsT4oKryBRpMHuWsCPW9LlhIrvh8dXI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [
    fontconfig
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    libsoup_3
    libX11
    wayland
    webkitgtk_4_1
  ];

  dontUnpack = true;
  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = "magpie";
      desktopName = "Magpie";
      comment = "One place to pick every agent's model";
      exec = "magpie %u";
      icon = "magpie";
      startupWMClass = "magpie";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "x-scheme-handler/magpie" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/magpie"
    install -Dm644 "$icon" "$out/share/icons/hicolor/scalable/apps/magpie.svg"
    install -Dm644 "$licenseFile" "$out/share/licenses/magpie/LICENSE"

    runHook postInstall
  '';

  preFixup = ''
    # Plugins need a Bun executable with a NixOS-compatible loader.
    gappsWrapperArgs+=(
      --set-default MAGPIE_BUN "${lib.getExe bun}"
      --prefix PATH : "${
        lib.makeBinPath [
          desktop-file-utils
          xdg-utils
        ]
      }"
    )
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/magpie" --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Desktop app and local model gateway for AI coding agents";
    homepage = "https://github.com/yetone/magpie";
    changelog = "https://github.com/yetone/magpie/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "magpie";
  };
})
