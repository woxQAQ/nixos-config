let
  # 系统主机密钥（每个系统独立 - 已经正确设置）
  woxQAQ-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPN7z6nJtSK4RlQJB4zFLUZ5h+QT6kEQVn9kOcMZzPK"; # woxQAQ 主机公钥
  woxMac-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAVB5rGXF8TrlRrKwRwUGju/yrenIqy78osPf9itUkq"; # woxMac 主机公钥

  # 用户密钥（建议每个系统的用户使用独立密钥）
  woxQAQ-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPN7z6nJtSK4RlQJB4zFLUZ5h+QT6kEQVn9kOcMZzPK"; # woxQAQ 上的用户密钥
  woxMac-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPN7z6nJtSK4RlQJB4zFLUZ5h+QT6kEQVn9kOcMZzPK"; # woxMac 上的用户密钥 - 建议替换为独立密钥

  # 管理员密钥（用于紧急访问和敏感操作）
  admin-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPN7z6nJtSK4RlQJB4zFLUZ5h+QT6kEQVn9kOcMZzPK"; # 独立的管理员密钥

  # 定义不同的访问级别
  nixosSystem = [woxQAQ-host woxQAQ-user]; # NixOS 系统访问
  darwinSystem = [woxMac-host woxMac-user]; # macOS 系统访问
  allSystems = [woxQAQ-host woxMac-host]; # 只有系统主机密钥
  allUsers = [woxQAQ-user woxMac-user]; # 所有用户密钥
  admins = [admin-key]; # 管理员密钥

  # 组合访问权限
  nixosWithAdmin = nixosSystem ++ admins; # NixOS + 管理员访问
  darwinWithAdmin = darwinSystem ++ admins; # macOS + 管理员访问
  all = allSystems ++ allUsers ++ admins; # 完全访问权限
in {
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
