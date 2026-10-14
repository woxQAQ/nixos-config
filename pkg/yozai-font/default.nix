{
  lib,
  stdenvNoCC,
  fetchurl,
}:

# Yozai (悠哉字体): a Chinese handwriting-style rounded font derived from
# YozFont, covering GB 2312. Releases ship plain TTFs, so we fetch each
# weight individually plus the OFL text required for redistribution.
let
  version = "0.868";
  mkWeight =
    name: hash:
    fetchurl {
      url = "https://github.com/lxgw/yozai-font/releases/download/v${version}/Yozai-${name}.ttf";
      inherit hash;
    };
in
stdenvNoCC.mkDerivation {
  pname = "yozai-font";
  inherit version;

  srcs = [
    (mkWeight "Light" "sha256-DvyEMwiBDATsOU2K8n0Ica2jqcxIYKImq96Iobxns70=")
    (mkWeight "Medium" "sha256-BfUPJStFGX0NYUikq8PjfHzUz98DyVW1fCXVPZJPg18=")
    (mkWeight "Regular" "sha256-JQcZmKD+anL1TCNecUmG0lljPl/2cLGiteJkOH8zFqw=")
    (fetchurl {
      name = "yozai-font-OFL.txt";
      url = "https://raw.githubusercontent.com/lxgw/yozai-font/v${version}/OFL.txt";
      hash = "sha256-hrOgtRYoSFAyQdgOqaMJpkWWkLp9xUeUB1impomlOwI=";
    })
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    for src in $srcs; do
      name=$(stripHash "$src")
      case "$name" in
        *.ttf) install -m444 -D "$src" $out/share/fonts/truetype/"$name" ;;
        *) install -m444 -D "$src" $out/share/doc/yozai-font/"$name" ;;
      esac
    done

    runHook postInstall
  '';

  meta = {
    description = "Chinese handwriting-style font derived from YozFont (悠哉字体)";
    homepage = "https://github.com/lxgw/yozai-font";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
