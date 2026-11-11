# Plan 002：用显式 profile 选择通用基础、开发工具与 GUI 工作站

> 执行者：逐步执行并运行所有验证；触发 STOP 条件时报告，不自行扩展范围。完成后更新 `plans/README.md`。
>
> 漂移检查：`git diff --stat 1a695a3..HEAD -- home/public/default.nix home/public/options.nix home/public/dev home/public/desktop/zed.nix home/public/shell_core.nix home/public/profiles home/public/media.nix outputs/woxQAQ.nix outputs/windows-vm1.nix outputs/wsl.nix outputs/selfcloud.nix outputs/woxDarwin.nix outputs/darwin-m1.nix tests/home-profiles.nix`。同时检查未提交修改。

## Status

- Priority：P1
- Effort：M
- Risk：MED，主机的软件集合将有明确的预期差异
- Depends on：none；推荐在 001 后执行，两个计划不共享源码文件
- Category：tech-debt
- Planned at：commit `1a695a3`, 2026-11-11

## Why this matters

`home/public` 是跨平台入口，却同时无条件安装完整开发工具、DBeaver 和默认 Kitty。审计求值确认 selfcloud 与 WSL 都启用 DBeaver、安装 Kitty；`modules.public.desktop.enable` 只控制 Zed，不能表达是否需要 GUI。用少量静态 profile 组合现有功能，让主机入口直接表达选择，避免每个小工具都增加一个 enable 开关。

## Current state

`home/public/default.nix:3` 的关键导入：

```nix
imports = [
  ./desktop
  ./dev
  ./helix
  ./neovim
  ./shell
  ./terminal
  # 其余现有通用配置
];
```

`home/public/dev/default.nix:12`：

```nix
programs.dbeaver = {
  enable = true;
  drivers = with pkgs; [ sqlite-jdbc ];
};
```

该文件还安装 Node、Rust、Python、protobuf、just、ast-grep 等，并配置 direnv。`dev/go.nix` 配置 Go 及工具链，`dev/npm.nix` 设置 npm/pnpm 的包发布时间限制，`dev/nix.nix` 安装 Nix 配置维护工具。不要更新其包版本或 source/hash。

`home/public/options.nix:33` 的 `terminal.emulators` 默认 `[ "kitty" ]`。`home/public/desktop/zed.nix:8` 读取 `config.modules.public.desktop`。`shell_core.nix:131` 无条件安装 ffmpeg-full、graphviz、imagemagick，另有 ups、glow。

所有六台主机都直接导入 home/public。`outputs/darwin-m1.nix` 实际导出的机器名是 woxMac-m1，其用户名不同于 woxMac；不要假设 Darwin 用户名统一。`outputs/selfcloud.nix` 还导入 home/agents，因此即使选择基础 profile，agents 仍会安装自身依赖 uv、pnpm、devenv、ast-grep 等。不能用“没有 pnpm”作为服务器基础 profile 的断言。

现有模块习惯是静态 imports 加局部 `mkIf`；终端以 emulators 列表选择应用。profile 表示一组静态导入和默认值，不是运行时状态，不新增 profile 枚举或 profile 解析框架。内部选项尚未作为公共接口发布，本次迁移所有调用者，不保留旧 desktop 选项别名。

## Target structure and behavior

新增三个可直接导入的入口：

```text
home/public/profiles/
  minimal.nix      # 导入 ../.，得到跨平台 CLI 与 Nix 维护基础
  developer.nix    # 导入 minimal + ../dev，增加开发工具，不安装 GUI
  workstation.nix  # 导入 developer + DBeaver + 媒体工具，选择 GUI 默认值
```

`home/public/default.nix` 保留 shell、git、gh、ssh、yazi、主题、mutable 检查、可选编辑器与终端的模块声明；移除无条件的 `./dev` 导入。显式导入 `./dev/nix.nix` 与 `./dev/npm.nix`：前者供所有机器维护 Nix，后者保留使用 pnpm 的 agents 所需发布时间策略。`dev/default.nix` 则导入 Go、cloud-native 等开发能力，不重复导入上述两个文件。

| 主机        | 入口        | GUI 开发工具             | 终端     | 其他决定                                      |
| ----------- | ----------- | ------------------------ | -------- | --------------------------------------------- |
| selfcloud   | minimal     | DBeaver=false，Zed=false | 无模拟器 | 保留 agents、原有 helix/tuios=false           |
| wsl         | developer   | DBeaver=false，Zed=false | 无模拟器 | 保留完整 CLI 开发工具                         |
| windows-vm1 | workstation | DBeaver=true，Zed=false  | Kitty    | 明确保留当前未启用 Zed 的行为                 |
| woxQAQ      | workstation | DBeaver=true，Zed=true   | Ghostty  | 保留现有编辑器与 cloud-native 选择            |
| woxMac      | workstation | DBeaver=true，Zed=true   | Ghostty  | 保留 hidpipe、字体、编辑器选择                |
| woxMac-m1   | workstation | DBeaver=true，Zed=true   | Ghostty  | 保留原有 cloud-native/neovim/playwright=false |

workstation 中用 `lib.mkDefault true` 选择新的 `modules.public.zed.enable`，并用 `lib.mkDefault [ "kitty" ]` 选择终端。其他 profile 不启用 Zed，终端默认列表为空。windows-vm1 明确设置 `modules.public.zed.enable = false`；其他三台工作站更新原有 `desktop.enable = true` 为 `zed.enable = true`。

将 shell_core 中 ffmpeg-full、graphviz、imagemagick 的安装迁到新增 `media.nix`，只由 workstation 导入。developer 已由 Go 工具安装 graphviz；不要顺带清理所有重复包。将 DBeaver 配置移到 `dev/dbeaver.nix`，只由 workstation 导入；底层 DBeaver Home Manager 选项仍由 mkHost/mkDarwin 的 sharedModules 提供，不改造它们。

## Commands you will need

| 用途               | 命令                                                                                                                                     | 成功结果                                       |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| 组合测试（新增后） | `nix eval --impure --no-update-lock-file --json --expr 'import ./tests/home-profiles.nix { flake = builtins.getFlake (toString ./.); }'` | 退出 0，全部具名用例为 true                    |
| 全主机求值         | `just check-hosts`                                                                                                                       | 四台 NixOS、两台 Darwin 均输出 drvPath，退出 0 |
| 静态检查           | `just check`                                                                                                                             | 退出 0                                         |
| 残留旧选项         | `rg -n 'modules\.public\.desktop                                                                                                         | cfg = config\.modules\.public\.desktop         | desktop\.enable' home/public outputs` | 无旧选项调用；退出 1，若匹配其他上下文则逐条检查 |
| diff 质量          | `git diff --check`                                                                                                                       | 退出 0                                         |

审计只确认了 NixOS 全主机求值；Darwin 曾在 60 秒窗口内超时，静态检查未运行，不能把它们记为通过。新增测试应使用直接 root flake 求值，避免误用 outputs/dev/flake.lock 中较旧的 root 快照。

## Scope

允许修改：

- `home/public/default.nix`、`options.nix`、`shell_core.nix`
- `home/public/dev/default.nix`、`dev/dbeaver.nix`（新增）
- `home/public/media.nix`（新增）
- `home/public/desktop/zed.nix`（仅选项归属迁移）
- 上述 `profiles/*.nix`（新增）
- 六个 outputs：`woxQAQ.nix`、`windows-vm1.nix`、`wsl.nix`、`selfcloud.nix`、`woxDarwin.nix`、`darwin-m1.nix`
- `tests/home-profiles.nix`（新增）
- `plans/README.md`（仅状态）

禁止修改：`home/public/helix/default.nix`；Noctalia 设置；`hosts/selfcloud/**`；系统模块；mkHost/mkDarwin；任何现有语言包定义、版本、hash；Nix inputs/锁文件；代理 profile、shell 行为及主题资源。

当前已观察到用户修改：`home/public/helix/default.nix`、`hosts/woxQAQ/configs/noctalia-settings.toml`，以及计划编写期间出现的 `home/public/shell/tuios/default.nix`。执行前重新记录完整 dirty 集合，结束时确认所有既有 diff 均未被改写。

## Git workflow

可使用独立分支 `advisor/002-home-profiles`。仅在操作者要求时提交，简短说明可用 `home configuration profiles`；不自动 push/PR/switch。新源码文件必须进入 Git flake 的可见范围，可在执行工作区对这些文件 `git add -N`，不要暂存用户文件。

## Steps

### 1. 记录主机级配置基线

为六台机器记录用户 programs 的 enable、终端选择、home.packages 的 pname/name 集合，输出到执行者的临时目录而非提交入库。不要导出完整配置或 secrets。创建测试文件，以完整主机为被测对象，先断言当前 shell/git/yazi 能力与现有编辑器选择。

**Verify**：基线版本的组合测试退出 0；`just check-hosts` 退出 0。若 Darwin 在当前环境无法完成，报告 BLOCKED，不删去 Darwin 测试。

### 2. 拆出 GUI 应用与 profile 入口

按 Target structure 创建三个 profile、DBeaver 与 media 文件。修改公共入口和终端默认值，迁移 Zed 选项。用静态 imports 组合，避免按 config 动态生成 imports。Zed 的设置正文和 DBeaver driver 配置原样保留。

**Verify**：用 `nix-instantiate --parse <file>` 分别解析新增和修改的 Nix 文件，均退出 0；`git diff --check` 退出 0。此时主机迁移尚未完成，不要求旧调用者完整求值通过；本步骤与下一步作为同一个逻辑变更交付。

### 3. 一次性更新六台主机的选择

严格按目标矩阵替换 home/public 入口与 Zed 选项。保留 hosts/home 导入、agents/hidpipe 导入及所有无关参数；selfcloud 仍然保留原有 helix/tuios=false。不要将 Home Manager 配置放进系统 `modules.public`，两者是不同配置空间。

**Verify**：`just check-hosts` 退出 0；旧选项残留搜索无匹配；实际求值的六台机器配置符合目标矩阵。

### 4. 完成组合回归测试

沿用 `home/public/catppuccin/check.nix` 的整套配置 assert 风格。测试返回每台机器的具名 true；Darwin 用对应 config 中实际用户名查 Home Manager 用户，不硬编码统一名字。

检查以下行为：

- 每台机器 git、nushell、yazi 仍启用，Nix 维护包仍存在。
- selfcloud：Go 关闭，home.packages 中 rustc 不存在、无 DBeaver/Kitty/Ghostty/Alacritty；agents 的核心工具仍存在；原有 helix/tuios 禁用。
- WSL：Go 开启，Rust/Node 开发工具保留，无 DBeaver 和终端模拟器。
- 四台工作站：DBeaver 和终端符合矩阵；Zed、neovim、helix、playwright、cloud-native 保留各自主机选择。
- 使用 selfcloud 的 `extendModules` 临时额外导入 developer profile：可获得 CLI 开发环境，DBeaver/终端仍不启用；不改磁盘或服务设置。
- 使用工作站测试覆盖将 terminal.emulators 强制设为空，三个终端均不启用，证明终端选择仍由列表控制。

**Verify**：组合测试全部 true；`just check` 和 `git diff --check` 退出 0。

## Test plan

这是主机配置组合的集成测试，不做函数单测或包列表全文快照。只检查功能边界及少量代表性包，避免无关包版本变化导致维护噪声。包列表基线仅用来审查实际移除的内容，允许差异只有计划明确的服务器/WSL GUI、服务器开发工具链、基础层媒体工具归属。

## Done criteria

- [ ] 六台主机均选择显式 profile，公共入口不会自动安装完整开发工具或 GUI。
- [ ] `tests/home-profiles.nix` 所有断言通过。
- [ ] `just check-hosts`、`just check`、`git diff --check` 退出 0。
- [ ] 旧的 `modules.public.desktop` 选项及调用者已删除，没有兼容别名。
- [ ] 工作站原有 GUI、字体、编辑器及用户已有修改保留。
- [ ] 修改仅限 Scope，索引状态更新。

## STOP conditions

- 移除 selfcloud 开发工具链后发现其现有自动化直接依赖其中某包：报告具体调用点，由维护者决定改选 developer 或补明确依赖，不能默默恢复整套工具。
- 基础 shell 或主题求值隐式依赖 dev 模块的选项，无法在当前范围内正确解除；先报告依赖，不用空值掩盖错误。
- 任一合理修复后仍连续两次验证失败；访问私有输入或平台能力不足时报告阻塞。
- 需要改动已有用户修改、语言包版本或系统服务才能继续。

## Maintenance notes

profile 负责选择功能，叶子模块负责配置功能。以后加入 GUI 数据库客户端应归入工作站组合；给服务器增加一种工具应显式选择，不回填进 public。若未来需要只含 CLI 的新工作环境，优先组合已有模块，不创建越来越多的 profile 枚举分支。
