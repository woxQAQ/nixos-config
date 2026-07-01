{
  pkgs,
  lib,
  config,
  ...
}:
let
  # 拉取 rime-ice 仓库
  version = "2026.06.30";
  rime-ice = pkgs.fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    name = "rime-ice-${version}";
    tag = version;
    hash = "sha256-HReBFYih39ohqZ2UAX6wPjjh0KuIauJPSOjk6ZXidss=";
    fetchSubmodules = false;
  };

  hasBeenInstalled =
    let
      files = [
        "${config.home.homeDirectory}/Library/Rime/installation.yaml"
      ];
    in
    builtins.all (file: builtins.pathExists file) files;
in
{
  home.file."Library/Rime" = {
    source = rime-ice;
    recursive = true;
  };
  # 使用 home manager 的激活脚本来处理安装
  home.activation.installRimeIce = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! ${lib.boolToString hasBeenInstalled} ]; then
      /Library/Input\ Methods/Squirrel.app/Contents/MacOS/Squirrel --install
    fi
  '';
}
