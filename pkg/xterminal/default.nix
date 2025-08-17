{
  stdenv,
  # undmg,
  fetchurl,
  _7zz,
}:
let
  dmgurl = "https://cdn-office.xterminal.cn/downloads/XTerminal-3.22.2-mac-arm64.dmg";
  dmghash = "zDuS+6ifCZncEEk2XXv7afVo/FDx1h+O3LdjdLYh79J9swQfJBAlD94mzqbo4BQzCUTDcDdFUinflcxXj34dmA==";
in
stdenv.mkDerivation {
  pname = "Xterminal";
  version = "3.22.2";
  src = fetchurl {
    url = dmgurl;
    curlOptsList = [
      "-H"
      "Referer: https://www.xterminal.cn"
      "-H"
      "Sec-Fetch-Site: same-site"
      "-H"
      "Sec-Fetch-Mode: navigate"
      "-H"
      "Sec-Fetch-User: ?1"
      "-H"
      "Sec-Fetch-Dest: document"
      "-H"
      "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"
    ];

    sha512 = "sha512-${dmghash}";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "Xterminal.app";
  installPhase = ''
    mkdir -p $out/{bin,Applications/Xterminal.app}
    cp -R . $out/Applications/Xterminal.app
    ln -s $out/Applications/Xterminal.app/Contents/MacOS/Xterminal $out/bin/Xterminal
  '';
}
