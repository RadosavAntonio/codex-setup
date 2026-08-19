# codex-setup

[![npm](https://img.shields.io/npm/v/@antonior/codex-setup?color=cb3837&logo=npm)](https://www.npmjs.com/package/@antonior/codex-setup)
[![license](https://img.shields.io/npm/l/@antonior/codex-setup?color=blue)](./LICENSE)
[![platform](https://img.shields.io/badge/platform-macOS-black?logo=apple&logoColor=white)](#platforms)
[![tokens](https://img.shields.io/badge/optimised%20for-low%20token%20usage-brightgreen)](#optimised-for-low-token-usage)

One command installer for my [OpenAI Codex](https://openai.com/codex/) configuration: global rules, hooks, agents, skills, permissions, memories, MCP tools, model defaults, and status line. Install once to get the portable setup I use every day. **Optimised for low token usage.**

## Why this setup?

Stock Codex is powerful but neutral. This configuration turns it into a careful, concise engineer with mechanical guardrails and explicit proof requirements.

- **🛡️ Trustworthy by default.** Global rules forbid fake completion claims, weakened tests, swallowed errors, `@ts-ignore`, and `eslint-disable`. Failures stay visible.
- **🔒 Catches mistakes before they ship.** `scan-secrets` blocks commits containing high confidence credentials or real `.env` files. `stop-verify` runs ESLint and TypeScript checks against changed files. `check-dep` requires package research before dependency additions.
- **🎯 Stays in scope.** Codex changes only what was requested or clearly required. Unrelated improvements are reported, not silently bundled.
- **🧠 Remembers across sessions.** Codex memories and saved history preserve useful decisions and preferences without shipping private history in this package.
- **💸 Uses fewer tokens.** Caveman mode removes filler while retaining technical substance. Verification hooks target changed files rather than whole repositories.
- **🧭 Uses focused agents.** `explorer` handles fast read only code search, `plan` handles architecture and implementation planning, `advisor` reviews difficult technical decisions, and `statusline-setup` makes targeted footer changes.
- **📱 Drives simulators and emulators.** `XcodeBuildMCP` builds, tests, and debugs against the iOS/macOS Simulator; the Android MCP server controls emulators and real devices through `adb`. `claude-video-vision` lets Codex watch and reason about video, and `context7` fetches current third party library documentation instead of relying on training data.
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
| Python 3 | Local transcript search and video FPS reminder | Required for transcript search; video reminder remains inactive without it |
| `git` | Commit scanning and changed file verification | Optional |
| `eslint`, `tsc` | Automatic linting and TypeScript verification | Optional; hooks no op when unavailable |
| Xcode | Apple builds, simulators, and UI automation | Required for `XcodeBuildMCP` |
| Android SDK and `adb` | Android device and emulator control | Required only for the manually installed Android MCP server |

## What it installs

Into `~/.codex/`:

- **`config.toml`**: model, reasoning, approval and permission defaults, memories, features, TUI, status line, and MCP servers
- **`AGENTS.md`**: global engineering, verification, scope, communication, planning, and safety rules
- **`hooks.json`** and **`hooks/`**
  - `scan-secrets.sh`: blocks commits containing likely secrets or real `.env` files
  - `check-dep.sh`: detects dependency additions and requests research
  - `eslint-fix.sh`: runs local ESLint fixes on edited JavaScript and TypeScript files
  - `stop-verify.sh`: checks changed TypeScript files with ESLint and `tsc`
  - `video-fps-reminder.py`: requests FPS before video analysis when missing
  - `notify-sound.sh`: plays completion sound unless muted
- **`agents/`**: `advisor`, `explorer`, `plan`, and `statusline-setup`
- **`rules/default.rules`**: reusable development command permissions
- **`transcript-search/`**: local Python MCP server for searching your own Claude Code conversation history

Into `~/.codex/skills/`:

- **`caveman`**: concise communication with technical substance preserved
- **`check-dep`**: dependency size, maintenance, compatibility, and alternative research
- **`debug`**: systematic root cause debugging workflow
- **`mute`** and **`unmute`**: completion sound control
- **`scan-secrets`**: staged secret and PII inspection before commits

Changed managed files are backed up to `<file>.bak`. Unmanaged files and directories are never deleted.
Legacy copies of the six package managed skills under `~/.agents/skills/` are moved recoverably to `<skill>.legacy.bak` after the current copies install under `~/.codex/skills/`. Other `.agents` content remains untouched.

## Configured MCP servers

Auto-registered in `config.toml` on install:

- **`transcript-search`** — full-text search over your *own* past **Claude Code** transcripts ("we talked about…", "like last time"), reachable from inside a Codex session. Pure Python standard library, no daemons or embeddings. The index is built **locally on your machine** from `~/.claude/projects/**/*.jsonl` on first use — nothing about your conversations is ever shipped in this package. If you don't also use Claude Code, this server has nothing to index and stays effectively idle.
- **`claude-video-vision`** — lets Codex watch and reason about video (frame extraction plus audio transcription). Published as [`claude-video-vision`](https://www.npmjs.com/package/claude-video-vision) on npm (pinned to `1.3.2`); run via `npx`. Needs its own API key on first use — see [On a new machine](#on-a-new-machine).
  - **Tip:** when asked for FPS, answer **0** for audio-transcription-only analysis — far cheaper on tokens than extracting frames. Only raise it when you need on-screen visual detail. The bundled `video-fps-reminder.py` hook prompts for this whenever it's missing from your request.
- **`context7`** — current, version-pinned third-party library and framework documentation, fetched live instead of relying on training data. Published as [`@upstash/context7-mcp`](https://github.com/upstash/context7#readme) on npm (pinned to `4.0.2`); run via `npx`.
- **`XcodeBuildMCP`** — build, test, drive the iOS/macOS **Simulator**, and debug from Codex without opening Xcode's UI. Published as [`xcodebuildmcp`](https://www.xcodebuildmcp.com) on npm (tracks `latest`, currently resolves to `2.7.0`); run via `npx`. Needs Xcode and its command line tools installed.
- **`android`** — controls Android **emulators** and physical devices via `adb`: screenshots, UI inspection, tap/swipe/type, logs, and app install/launch. Not npm-published, so it isn't auto-installed; clone and build it once, then it launches from the local path already wired into `config.toml`:
  ```sh
  mkdir -p ~/mcp-servers
  git clone https://github.com/martingeidobler/android-mcp-server.git ~/mcp-servers/android-mcp-server
  cd ~/mcp-servers/android-mcp-server
  npm install
  npm run build
  ```
  Requires the Android SDK and `adb` on `PATH`. Verify registration with `codex mcp list`.

  Security note: as checked on 19 August 2026, `android-mcp-server@1.3.0` depends on `sharp <0.35.0`; `npm audit --omit=dev` reports the high severity [GHSA-f88m-g3jw-g9cj](https://github.com/advisories/GHSA-f88m-g3jw-g9cj) advisory. Android setup therefore remains manual instead of being installed automatically. Review the upstream package before installation.

Register any additional MCP server yourself with `codex mcp add <name> -- <command>` (or `--url` for a streamable HTTP server); see `codex mcp --help`.

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
3. Give `claude-video-vision` its own API key if you use video analysis.
4. Optionally build the Android MCP server using the audited manual steps above, and install Xcode with its command line tools if you use `XcodeBuildMCP`.
5. Restart Codex and approve installed hooks.

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
- Trusted project paths

Home directory paths become `{{HOME}}` inside package and are rendered for target machine during installation.

The installed configuration currently uses workspace permissions, approval policy `on-request`, automatic approval review, generated memories, and several opt in Codex capabilities. Review [`files/codex/config.toml`](./files/codex/config.toml) before installation if those defaults do not suit you.

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

`scripts/sync-from-local.js` never copies credentials, histories, memories, runtime databases, sessions, caches, hook trust state, or trusted project paths.

## Publishing

```sh
npm version patch
npm publish --access public
```

## License

[MIT](./LICENSE) © Antonio Radosav

---

<p align="center">Made with ❤️ in the UK</p>
