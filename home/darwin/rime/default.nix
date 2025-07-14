{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  # 拉取 rime-ice 仓库
  rime-ice = pkgs.fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "7acdee60d09602383b6299d1bdaaba03f0a57869";
    hash = "sha256-yCVcTc8qitar5JJfVTH4xNJMTPgx/NsRMoTxVm5PVrY=";
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
