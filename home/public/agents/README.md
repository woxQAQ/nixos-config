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
- .agents/skills: skills directory that stores skills installed by `skills` cli
- skills.nix: entrypoint to mount skills to target agent dotfiles

## Skills

- ast grep
