{
  ...
}:
{
  # agenix 模块已在系统级别导入
  # agenix CLI 工具将在系统级别安装

  # 配置 agenix
  launchd.daemons."activate-agenix" = {
    serviceConfig = {
      StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
      StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    };
  };
  age = {
    # macOS 密钥存储路径
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets = {
      # "google-cloud-project-id" = {
      #   file = "${mysecret}/google-cloud-project-id.age";
      # };
    };
    # 用户密钥路径（可选）
    # secrets = {
    #   # 示例密钥配置
    #   # user-password.file = ../../secrets/user-password.age;
    #   # user-password.owner = "woxqaq";
    #   # user-password.group = "staff";
    #   # user-password.mode = "400";
    # };
  };
}
