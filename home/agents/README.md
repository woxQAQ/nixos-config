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
vendored files in this tree. Bumping a skill means changing its `rev`/`hash`
there; the overlay exposes the result as `pkgs.agent-skills`, whose
`passthru.skills` lists the skills linked into every supported agent directory.

- ast-grep, ast-grep-outline
- kill-ai-slop
- obelisk (the CLI itself is packaged as `pkgs.obelisk-cli`)
