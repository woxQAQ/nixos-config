# Global Agents Configuration

use llm-agents flake to apply agent.

## Support Agents

- pi
- codex(cli)
- kimi code
- grok

- t3code
- bb(cli)

## Layout

- default.nix: packages and generated global instructions for each agent
- skills.nix: mounts the skills packaged in pkg/agent-skills into each agent's dotfiles
- update-notifier/: macOS scheduled version checks, release notes, and notifications

## Pi 终端工具

在 Pi 中使用 `/review [revisions] [directory]` 打开 tuicr，使用
`/lazygit [directory]` 打开 lazygit；省略目录时使用当前会话的工作目录。
两者也分别注册了 `tuicr`、`lazygit` 工具供 agent 调用。打开时暂停 Pi 界面，退出后恢复会话。
`/lazygit` 的目录参数按完整路径读取，包含空格时无需加引号；相对路径基于会话目录。
需要本机已安装对应程序；lazygit 使用现有 Home Manager Git 配置。

扩展通过 `home/agents/pi/extensions/` 的可写链接加载，修改后在 Pi 中执行
`/reload` 即可生效。

## macOS 更新通知

导入本模块后，macOS 默认启用 `modules.agents.updateNotifier.enable`。
Home Manager 安装用户级 launchd 任务，每天按本机时区 **09:00、15:00** 检查。
睡眠期间错过的任务会在唤醒后合并运行一次；关机或退出登录期间不保证补跑。

检查清单与安装包共用配置，当前 `terminal` profile 包括
`pi、grok、codex、kimi-code、claude-code、tuicr`；`full` 跟踪 pi、t3code
及其选定的 providers。版本基准随系统切换一起生效，只修改 `flake.lock` 不会改变它。

1. 读取 `numtide/llm-agents.nix` 的最新 main 提交。若与已生效的提交相同，直接通知「没有更新」。
2. 提交不同时，由 Nix 求值对应平台、所选包的版本。仅更高版本视为更新，打包调整和版本回退不提醒更新。
3. 没有包更新时直接通知；有更新时，从各包 `meta.changelog` 指向的官方 GitHub releases
   获取 **llm-agents 可提供版本** 的说明。优先使用 Atom feed，旧条目回退到对应 tag 页面，避免匿名 API 限额。
4. 发送一条系统通知，包含版本变化与说明摘要；点击通知在浏览器查看完整报告和上游链接。
   报告在每次检查时覆盖，尚未安装的更新会在后续检查继续提醒。

Grok 从 [官方 Build changelog](https://x.ai/changelog/build) 的
[RSS](https://x.ai/changelog/build/rss.xml) 获取对应版本的说明，报告保留该版本的官方锚点链接。
目标版本缺失或抓取失败时，仍保留版本变化和官方链接，并标注说明不可用。
其他包的说明抓取失败也不会丢失更新提醒。
版本检查失败会通知「检查失败」，不会误报「没有更新」。脚本只检查，不更新 lock 或安装包。

通知由 Nix 提供的 `terminal-notifier` 发送。首次使用若 macOS 请求通知权限，请允许；
也可在「系统设置 → 通知 → terminal-notifier」启用通知。

配置切换后可手动运行：

```sh
llm-agents-check-updates
llm-agents-check-updates --no-notify
launchctl print "gui/$(id -u)/org.nix-community.home.llm-agents-update-notifier"
```

- 完整报告：`~/Library/Caches/llm-agents-update-notifier/latest.html`
- 任务日志：`~/Library/Logs/llm-agents-update-notifier.log`
- 禁用：在 Home Manager 配置中设置 `modules.agents.updateNotifier.enable = false;`

行为测试（需要 Python 3 和 Nix，使用本地 fixtures，不访问网络、不发送通知）：

```sh
python3 home/agents/update-notifier/test_check.py
```

## Skills

The skill sources are pinned upstream repos packaged by `pkg/agent-skills`, not
vendored files in this tree. Bumping a source means changing its `rev`/`hash`
there. The package installs all skills under each source's skill root (including
nested categories), using the `name` in `SKILL.md` frontmatter as the directory
name. Templates outside these roots are excluded.

Skills are stored at `share/skills/agent-skills/<source>/<name>` so different
sources can publish the same name without overwriting one another.

Choose which skills agents can use in `enabledSkills` in `home/agents/skills.nix`.
Its keys identify sources and its values list enabled skill names, for example:

```nix
mattpocock = [ "research" "teach" ];
pstack = [ "unslop" ];
```

Only selected skills are linked into every supported agent directory. Selected
names must be unique across sources because agent directories have a flat layout.
Keep delegated skills enabled together (for example, `grill-me` and `grilling`).
The obelisk CLI is packaged separately as `pkgs.obelisk-cli`.

## Neuve

`modules.agents.neuve.enable` 显式控制 CLI、skills 和仓库 setup，默认关闭，
不根据平台自动启用。Home Manager 配置示例：

```nix
modules.agents.neuve = {
  enable = true;
  route = "openai"; # anthropic / openai / claude
  repositories."/absolute/path/to/repository" = {
    hooks.enable = true;
    hooks.agents = [ "claude-code" "codex" ]; # [] 表示只安装 Git hooks
  };
};
```

启用后会安装 `package`（默认 `pkgs.neuve`），并将该包自带的 skill 通过
`agent-skills` 分发给各 agent；`skills.enable = false` 可单独关闭 skill。
每次 activation 都执行 `neuve setup --no-skills`，使用选定的 route 和当前包的
CLI、Graph 路径刷新仓库状态。仓库必须已存在，且有可供 Graph 检查的提交。
route 写入 Neuve 的用户设置；其他设置由 Neuve 保留。凭据仍需通过 provider
或 `neuve auth login` 配置，activation 不负责登录。

`hooks.enable` 默认关闭。启用后调用上游 `neuve setup hooks`，安装 Git hooks，
并合并、备份 Claude Code / Codex 的用户 hook 配置。Hook 使用 Home Manager
profile 中的稳定命令路径。`hooks.sessionTrailer` 默认关闭；`stack.enable`
默认关闭，开启后 hook setup 会拉取依赖源码。禁用模块或移除仓库配置不会
自动卸载已有 hooks，也不会删除 Records。

`pkgs.neuve` 在 Apple Silicon macOS 上使用 v0.2.1 官方发行包，在 x86_64 Linux
上从同一版本的源码构建 CLI、review desk 和锁定的 Graph 引擎，同时安装 semantic
workers、skills 和带文件校验值的安装清单。Linux 无需额外指定 `package`，沿用
上述 option 即可。两种平台共用一个版本号，更新脚本会刷新源码及依赖 hash，并
在 Linux 上构建、验证 setup 和 hooks；因此运行包更新需要 Linux builder。
`package` 仍可覆盖，需提供 `bin/neuve`、`lib/neuve/entire-graph`，以及启用
skill 时所需的 `share/neuve/skills`。
