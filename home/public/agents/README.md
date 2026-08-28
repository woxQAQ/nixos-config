# Global Agents Configuration

use llm-agents flake to apply agent.

## Support Agents

- pi
- codex
- kimi code
- grok

## Layout

- <agent>/AGENTS.md: global AGENTS.md for specific agent
- .agents/skills: skills directory that stores skills installed by `skills` cli
- skills.nix: entrypoint to mount skills to target agent dotfiles

## Skills

- ast grep

## future

- [ ] assembly pi extension
