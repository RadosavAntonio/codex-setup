# codex-setup

[![npm](https://img.shields.io/npm/v/@antonior/codex-setup?color=cb3837&logo=npm)](https://www.npmjs.com/package/@antonior/codex-setup)
[![license](https://img.shields.io/npm/l/@antonior/codex-setup?color=blue)](./LICENSE)
[![platform](https://img.shields.io/badge/platform-macOS-black?logo=apple&logoColor=white)](#platforms)
[![tokens](https://img.shields.io/badge/optimised%20for-low%20token%20usage-brightgreen)](#optimised-for-low-token-usage)

One command installer for my [OpenAI Codex](https://openai.com/codex/) configuration: global rules, hooks, agents, skills, permissions, memories, model defaults, and status line. Install once to get the portable setup I use every day. **Optimised for low token usage.**

## Why this setup?

Stock Codex is powerful but neutral. This configuration turns it into a careful, concise engineer with mechanical guardrails and explicit proof requirements.

- **🛡️ Trustworthy by default.** Global rules forbid fake completion claims, weakened tests, swallowed errors, `@ts-ignore`, and `eslint-disable`. Failures stay visible.
- **🔒 Catches mistakes before they ship.** `scan-secrets` blocks commits containing high confidence credentials or real `.env` files. `stop-verify` runs ESLint and TypeScript checks against changed files. `check-dep` requires package research before dependency additions.
- **🎯 Stays in scope.** Codex changes only what was requested or clearly required. Unrelated improvements are reported, not silently bundled.
- **🧠 Remembers across sessions.** Codex memories and saved history preserve useful decisions and preferences without shipping private history in this package.
- **💸 Uses fewer tokens.** Caveman mode removes filler while retaining technical substance. Verification hooks target changed files rather than whole repositories.
- **🧭 Uses focused agents.** `Explore` handles fast read only code search, `Plan` handles architecture and implementation planning, and `statusline-setup` makes targeted footer changes.
- **📊 Shows useful session state.** Status line shows directory, branch, model and reasoning, context use, token totals, and five hour and weekly limits.
- **⚡ Reproducible portable mirror.** Installer renders target home paths, backs up replaced files, leaves unmanaged files untouched, and remains safe to rerun.

## Install

```sh
npx @antonior/codex-setup
```

Restart Codex afterwards and approve installed hooks when asked. Installer is idempotent, so rerunning it safely refreshes managed files.

Use configuration only mode to skip requirement checks:

```sh
npx @antonior/codex-setup --config-only
```

## Platforms

Built and tested on **macOS**. Linux and native Windows are not officially supported yet because hooks use Bash, macOS sound playback, and local Unix paths.

## Dependencies

Installer checks dependencies but does not install software automatically.

| Tool | Used for | Requirement |
|------|----------|-------------|
| Codex CLI | Running configuration | Required |
| Node.js 18+ | Running installer | Required |
| `jq` | Hook command payload inspection | Optional; related hooks remain inactive without it |
| Python 3 | Video FPS reminder hook | Optional |
| `git` | Commit scanning and changed file verification | Optional |
| `eslint`, `tsc` | Automatic linting and TypeScript verification | Optional; hooks no op when unavailable |

## What it installs

Into `~/.codex/`:

- **`config.toml`**: model, reasoning, approval and sandbox modes, memories, history, features, trusted projects, TUI, status line, and OpenAI developer documentation MCP
- **`AGENTS.md`**: global engineering, verification, scope, communication, planning, and safety rules
- **`hooks.json`** and **`hooks/`**
  - `scan-secrets.sh`: blocks commits containing likely secrets or real `.env` files
  - `check-dep.sh`: detects dependency additions and requests research
  - `eslint-fix.sh`: runs local ESLint fixes on edited JavaScript and TypeScript files
  - `stop-verify.sh`: checks changed TypeScript files with ESLint and `tsc`
  - `video-fps-reminder.py`: requests FPS before video analysis when missing
  - `notify-sound.sh`: plays completion sound unless muted
- **`agents/`**: `Explore`, `Plan`, and `statusline-setup`
- **`rules/default.rules`**: reusable development command permissions

Into `~/.agents/skills/`:

- **`caveman`**: concise communication with technical substance preserved
- **`check-dep`**: dependency size, maintenance, compatibility, and alternative research
- **`debug`**: systematic root cause debugging workflow
- **`mute`** and **`unmute`**: completion sound control
- **`scan-secrets`**: staged secret and PII inspection before commits

Changed managed files are backed up to `<file>.bak`. Unmanaged files and directories are never deleted.

## Configured MCP server

The setup configures the official `openaiDeveloperDocs` MCP server at `https://developers.openai.com/mcp`. It provides current OpenAI developer documentation without connecting Codex to Claude or another private assistant history.

## Optimised for low token usage

This setup deliberately keeps responses and verification focused:

- **Compact global rules and Caveman mode** keep technical accuracy while removing filler and repeated startup instructions.
- **Focused agents** use a smaller read only model for code search and reserve deeper reasoning for planning work.
- **Scoped verification** runs ESLint and TypeScript checks against changed files.
- **Persistent memories** reduce repeated explanation across Codex sessions.
- **Visible context and token totals** make session cost and context pressure easy to track.

## On a new machine

Configuration is portable, but identity and machine trust are not. Complete these steps once:

1. Install and sign in to Codex.
2. Run `npx @antonior/codex-setup`.
3. Restart Codex and approve installed hooks.

Hook trust hashes are deliberately excluded because trust decisions belong to each machine.

## Security and privacy boundary

This package ships configuration and reusable tools only. It never ships:

- Codex or OpenAI credentials
- Prompt history or session transcripts
- Memories or rollout summaries
- Goals, logs, state databases, or shell snapshots
- OAuth locks
- Installation identifiers
- Plugin caches or downloaded system skills
- Hook trust decisions

Home directory paths become `{{HOME}}` inside package and are rendered for target machine during installation.

The installed configuration currently uses `danger-full-access`, approval policy `never`, saved history, generated memories, and trusted project paths. Review [`files/codex/config.toml`](./files/codex/config.toml) before installation if those defaults do not suit you.

## Maintaining

Package files come from an explicit portable allowlist. Refresh them from live Codex setup:

```sh
npm run sync
```

Prove package files match allowlisted live configuration:

```sh
npm run parity
```

Validate installer code and parity:

```sh
npm test
```

Before committing:

```sh
git add -A
./scripts/scan-staged.sh
```

`scripts/sync-from-local.js` never copies credentials, histories, memories, runtime databases, sessions, caches, or hook trust state.

## Publishing

```sh
npm version patch
npm publish --access public
```

## License

[MIT](./LICENSE) © Antonio Radosav

---

<p align="center">Made with ❤️ in the UK</p>
