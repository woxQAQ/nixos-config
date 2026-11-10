# 包更新检查与交互更新

统一入口会发现 `pkg/*/default.nix`，并运行对应的 `check-update.nu`。它只查询和比较，不修改版本、hash 或 lock 文件，不构建包，也不切换系统配置。需要 Nushell；若已登录 `gh`，会自动复用其 token。

```nu
# 检查全部包，默认最多同时运行 4 个包的检查。
nu scripts/check-pkg-updates.nu

# 仅检查指定包。
nu scripts/check-pkg-updates.nu agent-skills obelisk-cli

# 完整 JSON 输出，便于继续处理。
nu scripts/check-pkg-updates.nu --json --jobs 2

# 单独查询一个包，输出 JSON 数组。
nu pkg/agent-skills/check-update.nu
```

路径相对于脚本定位，可以在任意工作目录调用脚本。

并发以包为单位：统一入口使用 `par-each --threads $jobs`，默认同时检查最多 4 个包，`--jobs 1` 则串行检查。单个包内部的请求按顺序执行，例如 `agent-skills` 逐一查询 8 个来源，ChillRound 和 Noto 的分页也依次拉取。

## 来源与结果

各包脚本声明查询策略，共享实现位于 `scripts/lib/pkg-updates.nu`。当前支持：

- GitHub release：查询 GitHub 指定的最新稳定 release，移除 tag 开头的 `v` 后比较。
- ChillRoundF：遍历所有 release 分页，排除草稿和预发布，只从 `ChillRoundF_v*.zip` 附件提取全圆体版本。半圆体 `ChillRoundM` 使用独立版本序列，不参与比较。
- GitHub commit：比较本地固定的 rev 与远端默认分支 HEAD。`agent-skills` 自动读取每个字面量 `fetchFromGitHub` 块，逐来源报告；`v2dat` 使用同一策略。
- npm：查询 `latest` dist-tag。`obelisk-cli` 使用其实际下载来源 npm。
- Noto Sans：遍历 GitHub tags 的所有分页，只比较 `Sans` 系列，以自然顺序选择最新 tag。`inter-noto-sans-sc` 自身的 `1.0` 是本地组合包版本，因此检查外部 Noto 来源；Inter 由 nixpkgs 管理，随 flake input 更新。
- 依赖管理版本：`dbeaver-bin` 包装 nixpkgs 的 DBeaver；`ioskeley-chillround` 组合 nixpkgs 的 Ioskeley 与本仓库的 `chillroundf`。两者没有独立上游 pin，检查脚本返回 `skipped`；更新对应 flake input 或 `chillroundf` 即可。`skipped` 不检查这些依赖是否为最新版本。

结果包含 `package`、`source`、`current`、`latest`、`status`、`url`、`error`。单包脚本没有 `package` 列，该列由统一入口添加。

终端表格仅显示包、状态、当前版本、最新版本与来源，不显示行号；按终端宽度折行，commit 缩短为 12 位。URL 和完整 commit 保留在 `--json` 中；错误信息在单独的表格中展示。状态颜色为：`current` 绿色，`update` / `changed` 黄色，`ahead` 青色，`skipped` 灰色，`error` 红色。禁用 Nushell 的 ANSI 颜色或设置 `NO_COLOR` 可关闭颜色，JSON 始终使用原始状态字符串。

| status    | 含义                                                                            |
| --------- | ------------------------------------------------------------------------------- |
| `current` | 版本或 commit 相同；纯数字版本允许末尾补零                                      |
| `update`  | 上游纯数字版本高于本地，如 `0.3.0` → `0.3.1`                                    |
| `ahead`   | 本地纯数字版本高于上游，不建议降级                                              |
| `changed` | commit 或其他版本字符串不同，需人工判断；不推断 commit 祖先关系或预发布版本顺序 |
| `skipped` | 无独立上游 pin，版本由依赖管理；不需要单独更新                                  |
| `error`   | 查询、解析或检查脚本协议失败                                                    |

GitHub 的 `latest` 是其指定的 release，不一定是数值最大的 tag。例如上游可能把较老版本标成 latest，此时会报告 `ahead`。

统一入口完成所有检查后，只要有 `error` 就返回退出码 `1`；发现更新本身不导致失败。单包脚本返回 JSON 数据，来源级查询错误保留在数组内；统一入口根据这些记录决定退出码。缺少检查脚本的包也会明确报告错误。

GitHub 认证依次采用 `GITHUB_TOKEN`、`GH_TOKEN`、`gh auth token`；没有凭据则匿名查询，限流会作为错误报告。每个 HTTP 请求最多等待 20 秒。支持 `GITHUB_API_URL` 和 `NPM_CONFIG_REGISTRY` 覆盖 API 地址；默认分别为 `https://api.github.com` 和 `https://registry.npmjs.org`。

## 交互更新

`scripts/update-pkgs.nu` 复用检查入口，并通过 Nushell 的 `input list --multi --fuzzy` 选择具体更新来源。Tab 切换选择，Enter 执行，Esc 取消。仅列出 `update` 和 `changed` 项；`agent-skills` 的来源可单独选择。

```nu
# 检查全部包，交互选择要更新的项目。
nu scripts/update-pkgs.nu

# 只在指定包中选择。
nu scripts/update-pkgs.nu agent-skills magpie

# 预览全部候选项，不下载文件、不修改包。
nu scripts/update-pkgs.nu --all --dry-run

# 更新指定包的全部候选项，跳过交互选择。
nu scripts/update-pkgs.nu obelisk-cli --all
```

检查阶段沿用 `--jobs` 并发设置，实际更新按包串行执行。普通包先下载并计算所有 hash，准备完整文本，检查 Nix 语法，并确认原文件未在准备期间被修改，最后写回 `default.nix`。同一个包的多个技能来源一起准备、一起写回；某个下载失败不会留下半套版本与 hash。版本或 hash 文本不能唯一定位时会报错。

包内的 `update.nu` 维护下载来源，默认输出更新计划 JSON，供统一入口应用；它们不再次查询 latest，因此应用的版本就是交互选择时看到的版本。普通二进制包会更新所配置的所有架构，字体包会同时更新字体与许可证。共享的 `release-plan` 按 `default.nix` 中 hash 的出现顺序接收 URL 列表，新增或调整来源时必须同步修改包内列表。

Noto 的特殊更新逻辑位于 `pkg/inter-noto-sans-sc/update.nu`，仅更新外部 Noto URL 与 hash。`scripts/lib/pkg-update.nu` 保留通用的替换、预取和更新计划处理。

FlClash 使用包内的原生 Nushell 流程，更新带子模块的源码、Go/Rust 依赖 hash、Dart lock，并构建完整包。它需要 Linux，当前通过 `nixosConfigurations.woxQAQ.pkgs` 使用本仓库的依赖集。统一入口在执行前保存 `default.nix`、`pubspec.lock.json`、`git-hashes.json`，更新或构建失败时恢复这三个文件。旧的 `pkg/flclash/update.sh` 已删除。

更新入口需要 Nushell、Nix 和 `mktemp`；FlClash 若找不到 `nix-prefetch-git`，会通过本仓库固定的 nixpkgs 运行它。查询失败的来源会显示错误，其他可用来源仍可选择；任一查询或更新失败，最终退出码为 `1`。取消选择不修改包。脚本不提交 Git、不切换系统配置。

## 新增包

在包目录添加 `check-update.nu`，导入共享模块，返回一个非空 JSON 数组。例如：

```nu
#!/usr/bin/env nu
use ../../scripts/lib/pkg-updates.nu github-release

const package_file = path self default.nix

def main [] {
    [ (github-release $package_file 'owner/repo') ] | to json
}
```

`github-release` 要求 `default.nix` 中恰好有一处字面量 `version = "...";`。特殊包可以自行读取其固定版本，并用共享的 `result` 包装查询；解析不明确时应报错。无需在统一入口注册包。
