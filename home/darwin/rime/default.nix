{
  pkgs,
  lib,
  config,
  ...
}:
let
  version = "2026.06.30";
  rime-ice = pkgs.fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    name = "rime-ice-${version}";
    tag = version;
    hash = "sha256-HReBFYih39ohqZ2UAX6wPjjh0KuIauJPSOjk6ZXidss=";
    fetchSubmodules = false;
  };
in
{
  # 上游手动安装方式是把仓库全部文件放入 Rime 用户目录，这里以符号链接部署。
  # Squirrel 运行时产生的文件（installation.yaml、userdb、build/ 等）
  # 会落在同一目录下，与符号链接共存。
  home.file."Library/Rime" = {
    source = rime-ice;
    recursive = true;
  };

  # 上游要求更新配置后「重新部署」。--reload 通过分布式通知让运行中的
  # Squirrel 重新 deploy；用标记文件记录已部署的 store 路径，
  # 仅在 rime-ice 版本变化时触发，避免每次 switch 都全量部署。
  home.activation.deployRimeIce = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    squirrel="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
    marker="${config.home.homeDirectory}/Library/Rime/.nix-rime-ice-rev"
    if [ -x "$squirrel" ] && [ "$(cat "$marker" 2>/dev/null)" != "${rime-ice}" ]; then
      echo "${rime-ice}" > "$marker"
      "$squirrel" --reload || true
    fi
  '';
}
