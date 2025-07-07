{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  # 拉取 rime-ice 仓库
  rime-ice = pkgs.fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "7acdee60d09602383b6299d1bdaaba03f0a57869";
    hash = "sha256-yCVcTc8qitar5JJfVTH4xNJMTPgx/NsRMoTxVm5PVrY=";
    fetchSubmodules = false;
  };

  rimeDir = "${config.home.homeDirectory}/Library/Rime";
  rimeBakDir = "${config.home.homeDirectory}/Library/Rime.bak";
  squirrelExists = builtins.any (x: x.name == "squirrel-app") osConfig.homebrew.casks;
in {
  # 使用 home manager 的激活脚本来处理安装
  home.activation.installRimeIce = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # 检查 Squirrel 是否已安装
    if [ "${lib.boolToString (!squirrelExists)}" = "true" ]; then
      echo "Squirrel 输入法未安装，跳过 rime-ice 配置"
      echo "请先通过 homebrew 安装 squirrel-app"
      exit 0
    fi

    # 检查是否已经正确安装
    if [ -L "${rimeDir}" ] && [ "$(${pkgs.coreutils}/bin/readlink "${rimeDir}")" = "${rime-ice}" ]; then
      echo "rime-ice 已经正确安装，跳过安装步骤"
      exit 0
    fi

    echo "开始安装 rime-ice..."

    # 处理现有符号链接
    if [ -L "${rimeDir}" ]; then
      echo "删除现有的 Rime 符号链接"
      ${pkgs.coreutils}/bin/rm "${rimeDir}"
    fi

    # 处理现有目录（备份）
    if [ -d "${rimeDir}" ]; then
      if [ -e "${rimeBakDir}" ]; then
        timestamp=$(${pkgs.coreutils}/bin/date +%Y%m%d_%H%M%S)
        bakDir="${rimeBakDir}_$timestamp"
        echo "备份现有配置到 $bakDir"
      else
        bakDir="${rimeBakDir}"
        echo "备份现有配置到 ${rimeBakDir}"
      fi
      ${pkgs.coreutils}/bin/mv "${rimeDir}" "$bakDir"
    fi

    # 创建符号链接
    echo "创建 rime-ice 符号链接到 ${rimeDir}"
    ${pkgs.coreutils}/bin/ln -sf "${rime-ice}" "${rimeDir}"

    # 复制自定义配置文件
    echo "复制自定义配置文件..."
    ${pkgs.coreutils}/bin/cp "${./squirrel.custom.yaml}" "${rimeDir}/squirrel.custom.yaml"
    echo "已复制 squirrel.custom.yaml 到 ${rimeDir}"

    # 触发 Squirrel 重新部署
    echo "触发 Squirrel 重新部署..."
    if command -v osascript >/dev/null 2>&1; then
      # 使用 osascript 重启输入法服务
      osascript -e 'tell application "System Events" to keystroke " " using {option down, command down}'
      echo "已通过快捷键触发输入法重载"
    fi

    # 尝试直接调用 Squirrel 重新部署
    if [ -x "/Applications/Squirrel.app/Contents/MacOS/Squirrel" ]; then
      "/Applications/Squirrel.app/Contents/MacOS/Squirrel" --reload 2>/dev/null || true
      echo "已触发 Squirrel 重新部署"
    fi

    echo "rime-ice 安装完成！请重新启动输入法或重新登录以确保配置生效。"
  '';
}
