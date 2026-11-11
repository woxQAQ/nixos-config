# Plan 003：将 selfcloud 服务提取为可独立启用的 NixOS 模块

> 执行者：逐步执行并验证。此计划的目标是职责拆分，除本文明确的模块开关外，selfcloud 的运行行为必须保持。触发 STOP 条件时报告，不临时设计数据迁移。完成后更新 `plans/README.md`。
>
> 漂移检查：`git diff --stat 1a695a3..HEAD -- hosts/selfcloud/default.nix hosts/selfcloud/nas.nix hosts/selfcloud/gitea.nix hosts/selfcloud/services.nix hosts/selfcloud/tuning.nix modules/x86_64-linux/services tests/selfcloud-services.nix`。同时检查工作区修改；Plan 002 可先改变用户软件集合，与本计划的系统服务保持测试分别判断。

## Status

- Priority：P1
- Effort：M
- Risk：MED，涉及 NAS、已有服务状态和防火墙
- Depends on：none；推荐在 001、002 后执行以便逐项审查，源码范围互不重叠
- Category：tech-debt
- Planned at：commit `1a695a3`, 2026-11-11

## Why this matters

`hosts/selfcloud/nas.nix` 集合了文件共享与发现、媒体服务、下载 daemon、Intel 显示加速和网络调优。服务开关、主机部署参数及硬件政策混在一起，其他主机无法单独复用一种能力。提取四个独立模块后，hosts 只声明选择、地址、数据路径和机器条件，服务的通用集成在 modules 中维护。

## Current state

### 相关文件与事实

- `hosts/selfcloud/default.nix:8` 导入 hardware-configuration、disko、storage、nas、gitea、resource；还声明主机用户、SSH、node exporter、时区、boot loader、stateVersion 与系统维护工具。
- `nas.nix:13` 声明防火墙，手写 SSH/Samba/Jellyfin/qBittorrent 端口；各上游服务也会添加自己的发现端口。
- `nas.nix:34` 配置 Samba。全局包含 SMB3、权限策略、force user/group；两个共享的实际路径、valid users 是本机部署信息。
- `nas.nix` 的 samba-wsdd 与 avahi 提供 Windows/macOS 发现。Avahi 必须同时 publish addresses 和 SMB 服务记录；只开 wsdd 不满足 Finder 网络发现。保留当前 `%h`、`_smb._tcp`、`_device-info._tcp` XML 及发布设置。
- `nas.nix` 的 Jellyfin 配置使用 `/var/lib/jellyfin/config`、`/var/cache/jellyfin`；jellyfin 用户加入 videos/render/users；Intel VAAPI 包与 hardware.graphics 在同文件。
- `nas.nix` 的 sysctl 是本机部署调优，与服务启用没有必须绑定的关系。
- `storage.nix` 配置本机 mdadm、LVM、tmpfiles ACL、HDD bfq；`disko.nix` 描述已有 RAID5/LVM/btrfs；hardware-configuration 声明实际 UUID 挂载。这些留在 hosts。
- `resource.nix` 复用现有 zram 模块，设置 zram=100%、max-jobs=1、cores=2、禁用 NixOS 手册。它已经是明确的主机资源政策，不另建只有本机使用的资源框架。
- `hosts/selfcloud/home.nix` 为空；`fx-settings.json` 是用户应用设置，无证据表明被 Nix 配置引用。本次不处理它们。
- `outputs/selfcloud.nix` 已提供 agenix、disko、modules/public 和 Home Manager 组合。本次不改它。

### 必须保持的 qBittorrent 实现

`hosts/selfcloud/nas.nix` 当前使用自定义 daemon：

```nix
systemd.services.qbittorrent-nox = {
  description = "qBittorrent-nox";
  after = [ "network.target" "mnt-data.mount" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    User = username;
    Group = "users";
    IOSchedulingClass = "idle";
    ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/home/woxQAQ/.config/qBittorrent --webui-port=8080";
    Restart = "on-failure";
  };
};
```

审计检查了当前锁定 nixpkgs 的 `nixos/modules/services/torrent/qbittorrent.nix`：上游单元名是 `qbittorrent`，默认 `ProtectHome = "yes"`，profileDir 默认 `/var/lib/qBittorrent`，其文档明确不支持 home 中的 profile。因此本次保留自定义 `qbittorrent-nox` 单元，只提取与参数化；不替换上游服务，不迁移 profile，不改沙箱策略，不生成或覆盖运行时配置。

### Gitea

`hosts/selfcloud/gitea.nix` 当前启用 sqlite3、LFS、禁用注册，使用 `/var/lib/gitea`、HTTP 3000、内建 SSH 2222。地址、ROOT_URL、SSH_DOMAIN、appName 是主机部署参数，从原文件原样迁移，计划不复制实际地址。原文件用服务配置中的 HTTP_PORT/SSH_LISTEN_PORT 开放 TCP，并安装 `cfg.package`。继续保留这些行为。

### 已求值的 selfcloud 系统基线

- Samba、samba-wsdd、Avahi、Jellyfin、Gitea 都启用。
- TCP 端口集合：`[22,139,445,2222,3000,5357,8080,8096,8920]`。
- UDP 端口集合：`[137,138,1900,3702,5353,7359]`。
- qBittorrent User 为主机 username、Group=users、IOSchedulingClass=idle；after 为 network.target 与 mnt-data.mount。
- Gitea stateDir=/var/lib/gitea、database.type=sqlite3、lfs.enable=true。
- max-jobs=1、cores=2、zramSwap.memoryPercent=100。

端口按集合比较，不依赖 Nix 列表合并顺序。不要把“去重”误变成删除上游开放的 8920 或发现端口。

## Target architecture

```text
modules/x86_64-linux/services/
  default.nix       # 静态注册以下四个模块，导入本身不启用服务
  samba.nix         # Samba 与 SMB 局域网发现策略
  jellyfin.nix      # 媒体服务及通用默认值
  qbittorrent.nix   # 当前自定义 daemon 的类型化参数
  gitea.nix         # Gitea 的通用策略和防火墙集成

hosts/selfcloud/
  default.nix       # 导入 services.nix、tuning.nix 与原有机器模块
  services.nix      # 四个服务的选择与本机部署参数
  tuning.nix        # 原 nas.nix 中的 sysctl 和本机诊断工具
  storage.nix      # 原样保留：RAID/LVM、ACL、bfq
  resource.nix     # 原样保留：本机资源预算
  disko.nix、hardware-configuration.nix  # 原样保留
```

服务模块遵循 `modules/x86_64-linux/system/btrbk.nix` 的范式：局部 `cfg = config.modules...`，`mkEnableOption`/有类型的 `mkOption`，`config = lib.mkIf cfg.enable { ... };`。默认全部关闭，不加入 system/default.nix 或 desktop/default.nix 自动导入。

### 选项与归属的具体约束

**Samba：** 提供 `modules.services.samba.enable` 和 `discovery.enable`，后者默认 true，仅在 Samba 模块 enable 时生效。把当前 SMB3、sendfile、dos attributes、权限掩码等可复用策略保留在模块，用 `lib.mkDefault` 设置可覆盖的上游叶子值。发现启用时配置 samba-wsdd 和 Avahi 的现有发布策略/XML。共享路径、valid users、force user/group、server string、workgroup 留在主机的 `services.samba.settings`。防火墙选择直接使用上游 `services.samba.openFirewall`、`services.samba-wsdd.openFirewall`、`services.avahi.openFirewall`，由 selfcloud 显式设为 true，不另建重复开关。模块仅贡献正向设置，不在 disabled 分支强制关闭可能被其他功能使用的 Avahi。

**Jellyfin：** 提供 `modules.services.jellyfin.enable`，启用上游 Jellyfin。现有 configDir/cacheDir 可作为可覆盖的 `mkDefault`；主机明确保留当前路径。openFirewall 复用上游选项，由主机设为 true。用户附加组、hardware.graphics 与 Intel VAAPI 包留在主机 services.nix；模块不得隐含 Intel 硬件依赖。

**Gitea：** 提供 `modules.services.gitea.enable` 和 `openFirewall`（默认 false；上游当前没有 openFirewall）。启用时设置 sqlite3、LFS、禁用注册等现有通用策略，全部允许通过上游选项覆盖。主机通过 `services.gitea` 原生选项声明 appName、stateDir、ROOT_URL、HTTP_ADDR/PORT、内建 SSH 设置。防火墙端口从最终上游配置读取，不复制端口常量；只在 openFirewall 时开放 HTTP，且仅当 START_SSH_SERVER 为 true 时开放 SSH_LISTEN_PORT。继续安装最终 `config.services.gitea.package`。不封装另一套数据库/域名/端口选项。

**qBittorrent：** 提供 `modules.services.qbittorrent`，字段如下：

- enable：mkEnableOption，默认 false。
- package：types.package，默认 pkgs.qbittorrent-nox。
- user：types.str，无默认，必须显式配置。
- group：types.str，默认 users。
- profileDir：types.str，无默认，必须显式配置，并验证为绝对路径。
- webuiPort：types.port，默认 8080。
- openFirewall：bool，默认 false，仅控制 WebUI TCP 端口。

保留单元名、Description、Type、Restart、wantedBy、IOSchedulingClass；ExecStart 用 `lib.getExe` 和合适的 systemd 参数转义构造。不要在 shell 字符串中拼接用户输入。主机通过该模块显式指定现有 profileDir、username、group、8080 与 openFirewall=true；after 列表留在主机的 `systemd.services.qbittorrent-nox.after`，仍为原来两个依赖。不把 `mnt-data.mount` 硬编码进复用模块，不加强挂载依赖或更改 BFQ 策略。

主机 services.nix 显式导入新的 services/default.nix 并启用四项能力，同时承接原 nas.nix 的本机参数。删除已经迁完的 nas.nix 和 gitea.nix，避免两份定义。`default.nix` 保留主机用户、SSH、node exporter、时区、stateVersion、boot 和重建环境变量。

## Commands you will need

| 用途                   | 命令                                                                                                                                          | 成功结果                       |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ |
| selfcloud 完整求值     | `nix eval --no-update-lock-file --raw .#nixosConfigurations.selfcloud.config.system.build.toplevel.drvPath`                                   | 退出 0，输出 .drv 路径         |
| 服务组合测试（新增后） | `nix eval --impure --no-update-lock-file --json --expr 'import ./tests/selfcloud-services.nix { flake = builtins.getFlake (toString ./.); }'` | 退出 0，所有具名断言为 true    |
| 全主机求值             | `just check-hosts`                                                                                                                            | 四台 NixOS、两台 Darwin 均成功 |
| 静态检查               | `just check`                                                                                                                                  | 退出 0                         |
| diff 检查              | `git diff --check`                                                                                                                            | 退出 0                         |

实际审计已通过 selfcloud 完整系统求值及上述服务基线的定向求值。Darwin 全主机检查曾超时，不能预先标为成功。测试 fixture 使用 root flake，不依赖 dev 分区的旧 root 快照。

执行者不得运行 nixos-rebuild/darwin-rebuild switch，也不得运行 disko 的 format/mount、diskDestroyScript、mdadm/LVM 操作或修改实际数据目录。本任务完全可以通过求值与静态检查完成代码审查。

## Scope

允许修改：

- 新增 `modules/x86_64-linux/services/{default,samba,jellyfin,qbittorrent,gitea}.nix`
- `hosts/selfcloud/default.nix`（仅 imports）
- 新增 `hosts/selfcloud/services.nix`、`hosts/selfcloud/tuning.nix`
- 删除迁空后的 `hosts/selfcloud/nas.nix`、`hosts/selfcloud/gitea.nix`
- 新增 `tests/selfcloud-services.nix`
- `plans/README.md`（仅状态）

禁止修改：

- `hosts/selfcloud/storage.nix`、`disko.nix`、`hardware-configuration.nix`、`resource.nix`、`home.nix`、`fx-settings.json`
- `outputs/selfcloud.nix`（Plan 002 独立负责用户 profile）、其他主机/outputs
- 系统用户组或账号结构、私钥/密码/agenix 声明、所有数据库或运行时文件
- 现有 `modules/x86_64-linux/system` 与其他公共模块
- 任意 Nix input、flake.lock、输出架构或软件版本
- 已有用户修改：`home/public/helix/default.nix`、`hosts/woxQAQ/configs/noctalia-settings.toml`、`home/public/shell/tuios/default.nix`；执行前重新记录完整 dirty 集合，保留所有既有修改

## Git workflow

可在 `advisor/003-selfcloud-services` 执行。未获要求不提交；如要求提交可用简短主题 `selfcloud service modules`，不自动 push/PR/merge。新增源码需进入 Git flake 可见范围，在执行工作区仅对新文件使用 `git add -N`，不暂存用户已有修改。

## Steps

### 1. 固定服务与机器条件基线

创建集成测试文件，按 Current state 对真实 selfcloud 配置断言服务启用、端口集合、共享路径、用户身份、运行参数、Gitea state/database/LFS、Jellyfin 路径及资源预算。测试不读取 secrets，也不输出完整服务 environment 或配置。

额外把以下非敏感机器投影保存到执行者临时目录用于迁移前后比较：fileSystems、disko.devices、boot.swraid、boot/initrd LVM、systemd.tmpfiles.rules、udev.extraRules、sysctl、hardware.graphics、现有服务公开 endpoint、qBittorrent ExecStart/User/Group/after。只提取列明字段，不序列化全 config；配置中若出现秘密值则停止输出，只在内存比较。

**Verify**：基线测试退出 0；selfcloud 完整求值退出 0；四个禁止改动的机器配置文件与 git 基线一致。

### 2. 创建默认关闭的服务模块

按 Target architecture 建模块，所有 imports 静态声明。先不迁移主机。为 test fixture 使用 `flake.inputs.nixpkgs.lib.nixosSystem` 创建仅含新 services/default.nix 的 x86_64-linux 最小系统，设置虚拟 root fileSystem、关闭 boot loader 及 stateVersion，使完整系统求值合法，不导入私有 secrets、磁盘、home/public 或任何具体主机。

检查默认关闭时四个服务、qbittorrent-nox 单元和服务特有防火墙贡献都不存在。再用不同的测试用户名、profile 路径、共享路径与自定义 WebUI 端口启用对应模块，确认配置来自参数而非 selfcloud 常量。

**Verify**：组合测试的默认关闭与替代参数用例全部 true；生产 selfcloud 尚未迁移时仍满足基线。

### 3. 迁移 selfcloud 的服务声明和调优

新增 services.nix，显式导入并启用四个模块。把主机参数逐项移入；将原 nas 中的 sysctl、nmap/ffmpeg/mediainfo/ncdu 安装迁入 tuning.nix。所有设置值原样保留，尤其不要因为模块化顺带更改内网服务地址、目录、权限、端口或网络调优。

服务模块分别负责相关端口贡献，主机 firewall 保留 enable=true 与 SSH 的现有访问。删除 nas 中已由上游 openFirewall 或新模块负责的手写服务端口，确保最终端口集合与基线完全相等。不要把 Prometheus/node exporter 的配置移走或改变。

更新 default.nix 的 imports，删除 nas/gitea 旧文件。不要把 storage/resource 的内容为了减少 hosts 文件数量强行上提。

**Verify**：selfcloud 完整求值退出 0；服务基线测试通过；步骤 1 的机器投影迁移前后相等；`git diff -- hosts/selfcloud/storage.nix hosts/selfcloud/disko.nix hosts/selfcloud/hardware-configuration.nix hosts/selfcloud/resource.nix` 无输出。

### 4. 验证模块独立性和主机隔离

在最终 selfcloud 的 extendModules fixture 中，分别强制关闭一个 `modules.services.<name>.enable`，其他三项仍启用：

- Samba 关闭：samba、wsdd、由此模块贡献的 Avahi 服务/SMB 发布关闭；TCP 139/445/5357、UDP 137/138/3702/5353 不再由这些服务开放。
- Jellyfin 关闭：Jellyfin 关闭，8096/8920、1900/7359 不开放；本机 hardware.graphics 保留，不能被媒体服务开关删除。
- Gitea 关闭：Gitea 关闭，3000/2222 不开放。
- qBittorrent 关闭：qbittorrent-nox 单元不存在，8080 不开放；不能意外启用上游 `services.qbittorrent`。

针对最小 fixture 加一项 Samba discovery=false 用例：Samba 文件共享仍启用，但 wsdd 与 SMB Avahi 发布不由该模块启用。再加一个“外部模块启用 Avahi、Samba 模块关闭”的用例，确保不会强制关闭其他消费者。

替代参数 fixture 中 qBittorrent 用户、带空格的绝对 profile 路径与非默认 WebUI 端口必须正确传入最终 ExecStart；按 systemd 参数语义验证，不能要求未经转义的字符串全文相等。非法相对路径应触发明确的配置断言；测试可以通过 `builtins.tryEval` 强制求值 assertions 的通过条件来检查拒绝。

**Verify**：所有组合测试 true；`just check-hosts`、`just check`、`git diff --check` 退出 0。检查其他主机没有新增这四项服务或端口贡献。

## Test plan

采用 `home/public/catppuccin/check.nix` 的完整模块组合求值断言范式，不测试孤立 helper 函数。测试涵盖生产主机行为保持、默认关闭、四种独立关闭、discovery 关闭、共享 Avahi 协作、替代主机参数及路径校验。服务并未启动，因此不能声称 SMB/Finder、媒体播放、WebUI 或 Gitea 数据访问经过运行时验证。

## Done criteria

- [ ] 四个服务可独立启用；默认导入无服务与防火墙副作用。
- [ ] 生产 selfcloud 的路径、身份、qBittorrent profile/单元名/调度类别/after、Gitea endpoints/state/database/LFS、Jellyfin 状态与缓存路径均与基线一致。
- [ ] TCP/UDP 集合与 Current state 完全相同；独立关闭不留下该服务的专属开放端口。
- [ ] 通用模块不含 selfcloud 的 IP、share 路径、username、RAID/VG/UUID、mnt-data.mount 或 Intel 专用包。
- [ ] `tests/selfcloud-services.nix` 所有用例通过；`just check-hosts`、`just check`、`git diff --check` 通过。
- [ ] nas.nix/gitea.nix 无残留 imports，storage/disko/hardware/resource 原样保留。
- [ ] 没有修改磁盘、运行时数据、用户已有 diff 或锁文件；索引状态更新。

## STOP conditions

- 当前服务使用的路径或 upstream 选项与本文不符，尤其 qBittorrent 的真实 profile 位置不明确。
- 任一步要求数据库、目录、权限、daemon 身份或 service name 迁移。
- 发现端口差异、文件系统投影差异或 ACL/BFQ 行为变化，无法通过局部修复恢复；报告具体差异，不能接受为“清理”。
- 需要改动禁改文件、secret 配置、input 或运行 switch/disko 才能验证。
- 两次合理修复后同一验证仍失败，或私有输入/平台访问阻塞。

## Maintenance notes

服务的策略与本机部署参数分别维护。未来第二台 NAS 应复用具体服务模块，并声明自己的路径/身份/硬件，不导入 selfcloud。qBittorrent 自定义模块是当前 home profile 和单元名约束下的明确选择：未来如要改用上游，单独制定 profile 迁移、硬化策略与回滚计划。端口与发现配置的测试可防止后续调整再次破坏 Finder/Windows 局域网发现。
