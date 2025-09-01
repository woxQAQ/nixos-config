{
  # 系统特定的密钥配置示例

  # 仅 NixOS 系统使用的密钥
  # "nixos-config.age".publicKeys = nixosWithAdmin;

  # 仅 macOS 系统使用的密钥
  # "macos-config.age".publicKeys = darwinWithAdmin;

  # 跨系统共享但限制用户访问的密钥
  # "api-tokens.age".publicKeys = allSystems ++ admins;

  # 用户个人密钥（每个系统独立）
  # "woxQAQ-user-secrets.age".publicKeys = [woxQAQ-host woxQAQ-user admin-key];
  # "woxMac-user-secrets.age".publicKeys = [woxMac-host woxMac-user admin-key];

  # 高敏感度密钥（仅管理员访问）
  # "root-password.age".publicKeys = allSystems ++ admins;
  # "backup-encryption.age".publicKeys = admins;

  # 原有的示例配置（已更新为使用新的访问控制）
  # "wifi-password.age".publicKeys = allSystems;
  # "github-token.age".publicKeys = all;
  # "proxy-config.age".publicKeys = allSystems;
  # "email-config.age".publicKeys = allUsers ++ admins;
}
