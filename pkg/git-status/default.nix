{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "git-status";
  version = "1.0.0";

  src = ../../scripts;

  nativeBuildInputs = with pkgs; [
    makeWrapper
    python3
  ];

  installPhase = ''
    runHook preInstall

    # 创建 bin 目录
    mkdir -p $out/bin

    # 复制脚本并设置可执行权限
    cp $src/git_status.py $out/bin/git-stats
    chmod +x $out/bin/git-stats

    # 使用 makeWrapper 确保 python3 可用
    wrapProgram $out/bin/git-stats \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.python3
          pkgs.git
        ]
      }

    runHook postInstall
  '';

  meta = with lib; {
    description = "Git历史记录统计工具 - 显示每次提交的新增和删除行数";
    longDescription = ''
      Git历史记录统计工具，可以美观地显示每次提交的新增和删除行数。
      只使用Python标准库，无需安装第三方依赖。

      使用方法:
      - git-stats           # 显示最近50次提交
      - git-stats -n 20     # 显示最近20次提交
      - git-stats --no-color # 禁用颜色输出
    '';
    homepage = "https://github.com/your-username/nixos-config";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
