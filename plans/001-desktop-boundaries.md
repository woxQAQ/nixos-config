# Plan 001：明确 Linux 桌面共享配置与会话组件的边界

> 执行者：完整阅读后按步骤执行，每步通过验证再继续；触发 STOP 条件时报告原因。完成后更新 `plans/README.md` 的状态。
>
> 漂移检查：`git diff --stat 1a695a3..HEAD -- home/nixos/desktop tests/desktop-boundaries.nix`。同时检查工作区 diff；提交 SHA 不包含未提交修改。

## Status

- Priority：P1
- Effort：M
- Risk：MED，涉及桌面用户服务与会话工具归属
- Depends on：none
- Category：tech-debt
- Planned at：commit `1a695a3`, 2026-11-11

## Why this matters

系统已经用 `modules.desktop.environment` 选择 `gnome`、`niri` 或 `hyprland`，但用户桌面入口无条件启用 Noctalia，并把 `hyprshot` 放进所有桌面的基础软件集合。已求值确认 GNOME 主机 windows-vm1 的 `programs.noctalia.enable = true`，软件集合中也有 hyprshot。调整后，共享配置仍统一维护，面板、会话启动与桌面专用工具由所属会话负责。

## Current state

- `home/nixos/desktop/default.nix:3` 静态导入 base、browsers、cursor、fcitx、game、gtk、hyprland、mpv、niri、noctalia、pkgs、qt、xdg。
- `home/nixos/desktop/noctalia/default.nix:7` 导入上游 Home Manager 模块；末尾是 `programs.noctalia.enable = true;`，并无条件安装 gpu-screen-recorder。
- `home/nixos/desktop/base.nix:7` 在公共 `home.packages` 中安装 `hyprshot`。
- `home/nixos/desktop/hyprland/default.nix:14` 用 `cfg.environment == "hyprland"` 控制整个配置；内部显式 import `pkgs.nix` 等片段，并启用 Waybar、Mako、hypridle。
- `home/nixos/desktop/qt.nix:6` 的公共 Qt 设置无条件读取 `qt5ct/qt6ct/colors/noctalia.conf`，是关闭 Noctalia 时必须同时解除的隐式依赖。
- `home/nixos/desktop/niri/default.nix:8` 同样读取 `osConfig.modules.desktop`，仅在 environment 为 niri 时配置 niri 会话、polkit agent、xwayland-satellite。
- Niri 的 KDL 已依赖 Noctalia：`home/nixos/desktop/niri/conf/default.nix` 链接 `niri/noctalia.kdl`。
- `modules/x86_64-linux/desktop/options.nix` 的 environment 类型允许 null，默认 hyprland。
- `outputs/windows-vm1.nix` 选择 GNOME；`outputs/woxQAQ.nix` 选择 Niri。

遵循现有 `mkIf` 风格。例如 Niri 当前实现：

```nix
let
  cfg = osConfig.modules.desktop;
  enabled = cfg.environment == "niri";
in
{
  config = lib.mkIf enabled (...);
}
```

边界决定：继续由系统 environment 作为会话选择的单一事实来源。不要给 Home Manager 再增加独立的 environment 枚举。此次 Noctalia 是 Niri 会话组件；Hyprland 继续使用原有 Waybar/Mako 组合。null 的验收只要求没有会话专属组件；本计划不把整个桌面共享集合改造成无桌面 profile。

## Commands you will need

| 用途                   | 命令                                                                                                                                          | 成功结果                                        |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| 全主机求值             | `just check-hosts`                                                                                                                            | 退出 0，输出四台 NixOS 与两台 Darwin 的 drvPath |
| 仓库静态检查           | `just check`                                                                                                                                  | 退出 0；在 Nix sandbox 中检查，不直接改写工作区 |
| 桌面边界测试（新增后） | `nix eval --impure --no-update-lock-file --json --expr 'import ./tests/desktop-boundaries.nix { flake = builtins.getFlake (toString ./.); }'` | 退出 0，JSON 中全部用例为 true                  |
| diff 检查              | `git diff --check`                                                                                                                            | 退出 0                                          |

审计中四台 NixOS 的完整 derivation 求值通过；Darwin 求值在 60 秒观察窗口内未完成，不能当作已通过。`just check` 本轮未运行。新增测试命令在文件创建前不可运行。可以分主机执行求值并让每次调用拥有足够时间；超时必须记录为未完成。

## Scope

允许修改：

- `home/nixos/desktop/default.nix`
- `home/nixos/desktop/common.nix`（新增，共享配置的显式导入入口）
- `home/nixos/desktop/base.nix`
- `home/nixos/desktop/hyprland/pkgs.nix`
- `home/nixos/desktop/noctalia/default.nix`
- `home/nixos/desktop/qt.nix`（仅 Noctalia 调色板的条件归属）
- `tests/desktop-boundaries.nix`（新增，完整 NixOS/Home Manager 组合求值断言）
- `plans/README.md`（仅本计划状态）

禁止修改：系统桌面、boot、硬件、驱动、显示器参数；所有 KDL/CSS/JSON 资源；`hosts/woxQAQ/configs/noctalia-settings.toml`；Helix；锁文件和 flake inputs；其他计划的源码范围。

开始时工作区已存在 `home/public/helix/default.nix` 与 `hosts/woxQAQ/configs/noctalia-settings.toml` 的用户修改；计划编写期间 `home/public/shell/tuios/default.nix` 也出现修改。执行时重新记录完整 dirty 文件集合，保留所有既有 diff，不暂存、回退或格式化这些文件。

## Git workflow

- 可在独立分支 `advisor/001-desktop-boundaries` 执行；不要自动切换或覆盖用户现有工作。
- 仓库历史多用简短 `update`，也有 `selfcloud gitea` 等具体主题。只有操作者要求提交时才提交，可用简短说明 `desktop module boundaries`。
- 不自动 push、创建 PR、合并或切换系统。Nix 的 Git flake 会忽略全新未跟踪文件；在获授权的执行工作区中对新增源码使用 `git add -N <file>`，不暂存其他修改。

## Steps

### 1. 建立当前行为基线

运行主机求值，记录已有用户 diff。创建 `tests/desktop-boundaries.nix`，参数仅为 `{ flake }`，用仓库真实主机配置做集成断言。以 `flake.nixosConfigurations.windows-vm1` 为基础，通过其 `extendModules` 覆盖 `modules.desktop.environment = lib.mkForce ...`，分别求值 GNOME、Niri、Hyprland、null；不要用完整 woxQAQ 作为所有测试的基础，避免主机专属 Niri 文件干扰“未选择会话”的断言。

先对当前 GNOME/Niri 行为建立能通过的基线，包名用 `p.pname or p.name` 判断。采用 `home/public/catppuccin/check.nix` 的“整套配置求值 + assert”形式，返回具名 true 属性，不创建针对辅助函数的单元测试。不构建激活包、不启动任何服务。

**Verify**：基线测试命令退出 0；`git diff -- home/public/helix/default.nix hosts/woxQAQ/configs/noctalia-settings.toml` 与开始时一致。

### 2. 整理共享入口，收拢会话专属行为

新增 `common.nix`，显式导入当前除 hyprland、niri、noctalia 之外的共享模块。`default.nix` 只导入 common 与三个会话相关模块。保持静态 imports；不要从 `osConfig` 动态计算 imports，也不要认为父模块中的 `mkIf` 会自动关闭所有 imports。

在 Noctalia 模块内静态保留上游 import，把 `programs.noctalia.enable` 与 gpu-screen-recorder 的安装一起放进 `lib.mkIf (osConfig.modules.desktop.environment == "niri")`。将 hyprshot 从 base 移到 `hyprland/pkgs.nix`，该片段已由 Hyprland 条件配置包含。

同时修改 `qt.nix`：继续提供共享的 Fusion/qtct 配置，但 `Appearance.custom_palette` 只在 `config.programs.noctalia.enable` 时为 true；用 `lib.optionalAttrs` 仅在该条件下设置 `color_scheme_path`。关闭 Noctalia 时必须不引用其生成文件，使用 Fusion 自带调色板；不更换主题或增加新的调色板生成器。其余共享包、浏览器、GTK、输入法、游戏开关保持原有行为；不趁机重新选择截图工具。

**Verify**：`just check-hosts` 退出 0；Niri 仍启用 Noctalia，GNOME 中 Noctalia 为 false，hyprshot 仅出现在 Hyprland 的用户包集合。

### 3. 把测试升级为目标契约

最终测试必须明确断言：

| environment | Noctalia | hyprshot | 用户会话专属资源                                                                          |
| ----------- | -------- | -------- | ----------------------------------------------------------------------------------------- |
| gnome       | false    | 不存在   | 无 `.wayland-session`、无 Niri polkit agent、Hyprland HM enable=false                     |
| niri        | true     | 不存在   | 存在 Niri polkit agent、`.wayland-session` 与 `niri/config.kdl`，Hyprland HM enable=false |
| hyprland    | false    | 存在     | Hyprland HM enable=true、`.wayland-session` 存在、无 Niri polkit agent                    |
| null        | false    | 不存在   | 无上述用户会话资源                                                                        |

同时检查 gpu-screen-recorder 仅在 Niri 用例出现；Niri 的 Qt5/Qt6 设置 custom_palette=true 且保留 Noctalia 路径，其他三个用例 custom_palette=false 且没有 color_scheme_path。共享能力仍可求值。处理 Home Manager 属性时，对不存在的属性使用 `or` 或 `lib.attrByPath`，但存在与否本身需要断言，不得把默认值当作通过证据。

**Verify**：新增测试命令退出 0、所有具名用例为 true；`just check` 和 `git diff --check` 退出 0。

## Test plan

仅增加完整模块组合的求值测试，覆盖四种 environment。无需图形端 E2E 或函数单测。此次没有实际登录桌面，报告中明确登录行为未实机验证。后续用户自行切换时验证 Niri 面板、GNOME 登录和 Hyprland 原有面板即可；执行代理不能运行 switch。

## Done criteria

- [ ] 桌面边界测试全部返回 true。
- [ ] `just check-hosts` 和 `just check` 退出 0；如环境阻塞则标记 BLOCKED，不宣称完成。
- [ ] `rg -n hyprshot home/nixos/desktop/base.nix` 无匹配（退出 1），Hyprland 包文件有且仅有一处安装。
- [ ] `git diff --check` 退出 0，修改文件均在 Scope 内，已有用户 diff 原样保留。
- [ ] `plans/README.md` 状态更新，注明仅求值检查、未切换系统。

## STOP conditions

- 上述当前代码已漂移，或发现当前真实 Hyprland 会话依赖 Noctalia；先报告具体依赖，不直接删除。
- 测试需要修改 KDL、显示器、系统驱动或用户已有修改才能通过。
- 任一步合理修复后仍连续两次失败；私有 secrets 输入不可访问时记录环境阻塞，不更换 input。

## Maintenance notes

新增会话应在自己的模块内声明专用工具，不能追加到 common。Noctalia 若未来被其他会话采用，应新增明确的桌面组合选择，再考虑独立选项。仍保留的共享应用与 MIME 偏好是当前个人桌面集合，不在此次假装完成通用发行版式的桌面抽象。
