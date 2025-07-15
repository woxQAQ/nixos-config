{
  config,
  lib,
  ...
}:
{
  # 这是一个示例文件，展示如何在配置中使用 agenix 密钥
  # 取消注释并根据需要配置实际的密钥

  # 配置密钥
  age.secrets = {
    # 示例：用户密码
    # user-password = {
    #   file = ../../../secrets/user-password.age;
    #   owner = "woxQAQ";
    #   group = "users";
    #   mode = "400";
    # };

    # 示例：GitHub Token
    # github-token = {
    #   file = ../../../secrets/github-token.age;
    #   owner = "woxQAQ";
    #   group = "users";
    #   mode = "400";
    # };

    # 示例：SSH 私钥
    # ssh-private-key = {
    #   file = ../../../secrets/ssh-private-key.age;
    #   owner = "woxQAQ";
    #   group = "users";
    #   mode = "400";
    #   path = "/home/woxQAQ/.ssh/id_ed25519";
    # };
  };

  # 使用密钥的示例配置
  # 例如，在环境变量中使用 GitHub Token：
  # environment.variables = {
  #   GITHUB_TOKEN = "$(cat ${config.age.secrets.github-token.path})";
  # };

  # 或者在服务配置中使用：
  # systemd.services.some-service = {
  #   script = ''
  #     export SECRET=$(cat ${config.age.secrets.user-password.path})
  #     # 使用密钥的逻辑
  #   '';
  # };
}
