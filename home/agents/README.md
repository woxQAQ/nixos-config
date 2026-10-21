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

## Skills

The skill sources are pinned upstream repos packaged by `pkg/agent-skills`, not
vendored files in this tree. Bumping a skill means changing its `rev`/`hash`
there; the overlay exposes the result as `pkgs.agent-skills`, whose
`passthru.skills` lists the skills linked into every supported agent directory.

- ast-grep, ast-grep-outline
- kill-ai-slop
- obelisk (the CLI itself is packaged as `pkgs.obelisk-cli`)
