# Agenix 密钥管理

这个目录包含使用 [agenix](https://github.com/ryantm/agenix) 管理的加密密钥文件。

## 初始设置

### 1. 获取系统公钥

首先需要获取你的系统的 SSH 主机公钥：

```bash
# 在 NixOS 系统上
sudo cat /etc/ssh/ssh_host_ed25519_key.pub

# 在 macOS 上
sudo cat /etc/ssh/ssh_host_ed25519_key.pub
```

### 2. 获取用户公钥

```bash
# 生成用户密钥对（如果还没有）
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

# 查看公钥
cat ~/.ssh/id_ed25519.pub
```

### 3. 更新 secrets.nix

将获取到的公钥更新到 `secrets.nix` 文件中，替换示例公钥。

## 使用方法

### 创建新密钥

1. 编辑 `secrets.nix`，添加新的密钥配置：
   ```nix
   "my-secret.age".publicKeys = [ woxQAQ user ];
   ```

2. 创建密钥文件：
   ```bash
   # 进入 secrets 目录
   cd secrets/
   
   # 使用 agenix 创建新密钥
   agenix -e my-secret.age
   ```

3. 在 NixOS 配置中使用密钥：
   ```nix
   age.secrets.my-secret = {
     file = ./secrets/my-secret.age;
     owner = "woxQAQ";
     group = "users";
     mode = "400";
   };
   ```

### 编辑现有密钥

```bash
agenix -e my-secret.age
```

### 查看密钥内容

```bash
agenix -d my-secret.age
```

## 常见用例

### 1. 存储 API Token

```nix
# secrets.nix
"github-token.age".publicKeys = all;

# 在配置中使用
age.secrets.github-token = {
  file = ./secrets/github-token.age;
  owner = "woxQAQ";
  group = "users";
  mode = "400";
};

environment.sessionVariables = {
  GITHUB_TOKEN = "$(cat ${config.age.secrets.github-token.path})";
};
```

### 2. 存储用户密码

```nix
# secrets.nix
"user-password.age".publicKeys = [ woxQAQ user ];

# 在配置中使用
age.secrets.user-password = {
  file = ./secrets/user-password.age;
  owner = "root";
  group = "root";
  mode = "400";
};

users.users.woxQAQ.hashedPasswordFile = config.age.secrets.user-password.path;
```

### 3. 存储 SSH 私钥

```nix
# secrets.nix
"ssh-private-key.age".publicKeys = all;

# 在配置中使用
age.secrets.ssh-private-key = {
  file = ./secrets/ssh-private-key.age;
  owner = "woxQAQ";
  group = "users";
  mode = "400";
  path = "/home/woxQAQ/.ssh/id_ed25519";
};
```

## 安全注意事项

1. **永远不要**将解密的密钥文件提交到 Git
2. 确保 `.gitignore` 文件正确配置
3. 定期轮换密钥
4. 使用最小权限原则设置文件权限
5. 备份你的私钥文件（在安全的地方）

## 故障排除

### 无法解密密钥

确保：
- 系统的 SSH 主机密钥存在并可访问
- `secrets.nix` 中的公钥是正确的
- 密钥文件的权限设置正确

### 重建时密钥未更新

agenix 在系统重建时会自动解密密钥到 `/run/agenix/` 目录。如果密钥没有更新，尝试：

```bash
sudo systemctl restart agenix
``` 