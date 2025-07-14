{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "gemini-cli";
  version = "early-access";

  src = pkgs.fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "early-access";
    hash = "sha256-KNnfo5hntQjvc377A39+QBemeJjMVDRnNuGY/93n3zc=";
  };

  npmDepsHash = "sha256-/IAEcbER5cr6/9BFZYuV2j1jgA75eeFxaLXdh1T3bMA=";

  # 包含必要的构建输入
  nativeBuildInputs = with pkgs; [
    makeWrapper
    nodejs
  ];

  # 构建脚本
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    # 安装到 lib 目录
    mkdir -p $out/lib/node_modules/@google/gemini-cli
    cp -r . $out/lib/node_modules/@google/gemini-cli/

    # 创建可执行文件 - 使用正确的路径
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/gemini \
      --add-flags "$out/lib/node_modules/@google/gemini-cli/packages/cli/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Gemini CLI - An AI agent for your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
