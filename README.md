# codex-setup

[![npm](https://img.shields.io/npm/v/@antonior/codex-setup?color=cb3837&logo=npm)](https://www.npmjs.com/package/@antonior/codex-setup)
[![license](https://img.shields.io/npm/l/@antonior/codex-setup?color=blue)](./LICENSE)
[![platform](https://img.shields.io/badge/platform-macOS-black?logo=apple&logoColor=white)](#requirements)

One command installer for Antonio's Codex configuration. It installs global rules, model and interface defaults, hooks, agents, personal skills, command permissions, memories settings, and status line configuration.

## Install

```sh
npx @antonior/codex-setup
```

Restart Codex afterwards. Codex will ask you to approve installed hooks because hook trust state is deliberately machine local.

Use configuration only mode to skip requirement checks:

```sh
npx @antonior/codex-setup --config-only
```

## What it installs

Into `~/.codex`:

- `config.toml`: model, reasoning, safety mode, memories, TUI, trusted projects, status line, features, and OpenAI developer documentation MCP
- `AGENTS.md`: durable global engineering and communication rules
- `hooks.json` and `hooks/`: secret scanning, dependency checks, ESLint fixes, changed TypeScript verification, video FPS reminder, caveman activation, and completion sound
- `agents/`: `Explore`, `Plan`, and `statusline-setup`
- `rules/default.rules`: reusable development command permissions

Into `~/.agents/skills`:

- `caveman`
- `check-dep`
- `debug`
- `mute`
- `scan-secrets`
- `unmute`

Changed managed files are backed up to `<file>.bak`. Unmanaged files and directories are never deleted.

## Privacy boundary

Package ships configuration and reusable tools only. It never ships:

- Codex or OpenAI credentials
- Prompt history or session transcripts
- Memories or rollout summaries
- Goals, logs, state databases, or shell snapshots
- OAuth locks
- Installation identifiers
- Plugin caches or downloaded system skills
- Hook trust decisions

Home directory paths become `{{HOME}}` in package and are rendered for target machine during installation.

## Requirements

- macOS
- Node.js 18 or newer
- Codex CLI
- `jq` for command inspection hooks
- Python 3 for video FPS reminder hook

Installer checks requirements but does not install software automatically.

## Behaviour

This package intentionally reproduces Antonio's current preferences, including `danger-full-access`, approval policy `never`, saved history, generated memories, trusted project paths, caveman responses, and automatic edit verification. Review `files/codex/config.toml` before installing if those defaults do not suit you.

## Maintaining

Refresh portable files from live setup:

```sh
npm run sync
```

Prove package files match allowlisted live configuration:

```sh
npm run parity
```

Validate code and parity:

```sh
npm test
```

Before committing:

```sh
git add -A
./scripts/scan-staged.sh
```

`scripts/sync-from-local.js` uses an explicit allowlist. Do not widen it to runtime or private data.

## Publishing

```sh
npm version patch
npm publish --access public
```

## Licence

MIT © Antonio Radosav
