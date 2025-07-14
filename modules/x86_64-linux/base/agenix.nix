{
  config,
  pkgs,
  ...
}:
{
  # agenix 模块已在系统级别导入
  # agenix CLI 工具将在系统级别安装

  # 配置 agenix
  age = {
    # 密钥存储路径
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    # 用户密钥路径（可选）
    # 如果用户有自己的密钥，可以取消注释
    # secrets = {
    #   # 示例密钥配置
    #   # user-password.file = ../../../secrets/user-password.age;
    #   # user-password.owner = "woxQAQ";
    #   # user-password.group = "users";
    #   # user-password.mode = "400";
    # };
  };
}
