# Codex CLI Optimization Tracking

Current release catch-up notes, applied optimizations, pending considerations,
and version history for Codex CLI. The runtime overview lives in `codex-cli.md`.

## 1. Optimization Tracking

Last reviewed Codex CLI version: v0.144.4 (2026-07-15)

Review confirmation (2026-07-15): local `codex --version` reported
`codex-cli 0.144.4`, and the official `openai/codex` release
`rust-v0.144.4` is the latest stable release. Newer
`rust-v0.145.0-alpha.*` releases are prereleases and are not treated as active
local behavior.

### 1.1. Release Catch-up (v0.136.0 -> v0.144.4)

Stable releases through the locally installed `codex-cli 0.144.4` add mostly
product/runtime capabilities rather than required dotfiles config changes:

- v0.144.4 is a patch release with no user-facing changes.
- v0.144.3 is a version-only release with no merged PR changes after v0.144.2.
- v0.144.2 restores the previous Guardian auto-review policy, request format,
  and tool behavior after a prompting regression. No local config change.
- v0.144.0 adds usage-limit reset-credit selection, `writes` app approval mode,
  interactive MCP authentication by default, runtime Codex auth for app-server
  hosts, global pnpm-install detection, Ultra reasoning concurrency warnings,
  Code Mode and Windows sandbox fixes, terminal-control sanitization, app auth
  refresh fixes, WebSocket proxy/custom CA preservation, faster review branch
  picking, plugin skill-loading speedups, and Bedrock model display updates.
  No generated config change: keep app connector approvals at `prompt` because
  switching to `writes` would allow read-only Gmail/Drive/Calendar/Slack tool
  calls without a prompt, which is a privacy-policy change rather than a pure
  compatibility update.
- v0.143.0 enables remote plugins by default, adds system-proxy routing for
  authentication and Responses API traffic, adds `codex remote-control pair`,
  adds Amazon Bedrock GPT-5.6 Sol/Terra/Luna plus `max` reasoning effort,
  defaults MCP tools to tool search, adds ChatGPT-hosted MCP session auth,
  extends app-server environment/thread/fork APIs, reduces installer GitHub API
  rate-limit failures, and lands the remaining persistent-log write reduction
  for the Codex WAL-bloat incident. No local config change.
- v0.142.5 is a maintenance patch that redacts full Responses WebSocket request
  payloads from trace logs (openai/codex #30771). No user-facing behavior
  change; no config change.
- v0.142.4 has no user-facing changes.
- v0.142.3 is a maintenance-only patch with no user-facing changes after
  v0.142.2.
- v0.142.2 turns MCP tool search on by default when supported, adds opt-in
  macOS system-proxy auth support, adds plugin dark-mode logos, improves
  Bedrock credential errors, rejects uninspectable PowerShell AST regions, and
  quiets successful formatter runs.
- v0.142.0 adds `/usage` reset-credit redemption, remote plugin organization
  and suggestions, configurable rollout token budgets, configurable app-server
  multi-agent delegation, indexed web search, scheduled/current-time reminders,
  better remote environment path/shell/sandbox preservation, plugin loading
  fixes, parent-visible terminal subagent errors, and reduced startup/log churn.
- v0.141.0 adds authenticated encrypted Noise relay channels for remote
  executors, cross-platform remote execution path preservation, plugin-scoped
  stdio MCP activation, child-thread/app-server credit APIs, input
  auto-resolution, a bundled SQLite WAL-reset corruption fix, and large-session
  latency/memory reductions.
- v0.140.0 adds `/usage` activity views, permanent session deletion, `/import`
  from Claude Code, default unified mentions, managed Bedrock auth, encrypted
  local credential storage, SQLite state rebuild from rollouts, and the removal
  of experimental TUI `/realtime` voice controls.
- v0.139.0 improves code-mode web search, schema preservation, `codex doctor`,
  plugin marketplace automation, resume/fork prompt parsing, MCP warning
  scoping, image-edit path selection, and proxy-aware sandbox behavior.
- v0.138.0 adds `/app` handoff to Codex Desktop, model-defined reasoning effort
  ordering, account token usage APIs, v2 personal access tokens, richer plugin
  JSON/detail surfaces, better goal behavior, config write diagnostics, and
  more accurate workspace instruction loading.
- v0.137.0 expands TUI controls, enterprise/admin cloud-managed config flows,
  remote-control grant APIs, plugin list JSON/cache suggestions, hosted
  web/image tool availability, and multi-agent v2 metadata/runtime handling.
- v0.136.0 adds clickable OSC 8 markdown links, session archive/unarchive,
  `codex app-server --stdio`, short-lived remote-control server tokens, alpha
  elevated Windows sandbox setup, command-safety hardening, improved sandbox
  cleanup/read-deny enforcement, and refreshed built-in OpenAI Docs skill
  routing.

Local decisions from this catch-up:

- No generated `config.toml` change is needed for MCP tool search, indexed web
  search, apps, plugins, or time reminders. Current config already keeps
  `web_search = "live"`, enables apps globally while disabling destructive/open
  world defaults, and keeps app tool approvals at `prompt`.
- Keep `features.fast_mode = false`; no release in this range changes the
  rationale that launch-time model/reasoning pins should not be swapped by
  `/fast`.
- The Codex WAL checkpoint and storage-pressure timers were removed on
  2026-07-05 after the v0.142.0 log-write fixes (see §1.2).
- Treat Code Mode, rollout token budgets, multi-agent delegation controls,
  system-proxy auth, and custom API/Bedrock/admin surfaces as product features
  until a local harness workflow needs explicit config.

### 1.2. WAL Bloat (resolved upstream)

Codex logs SQLite WAL growth (observed at 32-35 GB locally in 2026-05) was
fixed upstream: openai/codex #29432 and #29457 landed in v0.142.0 and #29599
landed in v0.143.0, removing ~85% of persistent log writes. The local
checkpoint and pressure-relief timers were removed on 2026-07-05. The full
incident runbook is archived in the private vault
(2026-07-05-storage-hygiene-playbook-retirement). Sessions under
<!-- private-content-scan: allow-next-line -->
`~/.codex/sessions/` still have no upstream auto-retention
(openai/codex #20230); use `codex delete` / archive for manual cleanup.

### 1.3. Applied Optimizations

- [x] Runtime-root instruction file removed; persona and scope now flow through
  `config/tmux-a2a-postman/postman.md`; applicable skills flow through the
  generated `skill_path` catalog, while catch-all repo background lives in docs
- [x] skills/ symlinked to Claude Code skills
- [x] Shared Bash command-deny policy enforced through the Codex
  `PreToolUse` matcher=`Bash`; `default.rules` is not generated for the
  shared deny set.
- [x] Home-level Codex hooks reduced to the load-bearing minimum:
  `UserPromptSubmit` (shared `common-userpromptsubmit.sh codex`) and
  `PreToolUse` matcher=`Bash` (shared `pretooluse-deny-bash.sh`).
  Removed 2026-04-29: `SessionStart` (`codex-sessionstart-reload.sh`),
  `PostToolUse` matcher=`Bash` (`codex-posttooluse-review.sh`), and
  `Stop` (`codex-stop-save.sh`) — see commit `6add5abb`.
- [x] Shared deny-bash patterns reused by both Claude Code and Codex CLI hooks
  (`denied-bash-commands.nix` SSOT; both runtimes consume).
- [x] Shared deny-bash *script* now also shared, not just the patterns:
  `pretooluse-deny-bash.sh` (no runtime prefix) is invoked by both
  Claude and Codex. Replaced the previous `codex-pretooluse-deny-bash.sh`
  fork that had drifted (missed `is_allow_prefix_bypass`,
  `strip_data_arg_values`, and the in-session `\s` -> `[[:space:]]`
  and sed delimiter fixes). See commit `5fb7e44a`.
- [x] Shared deny-bash justifications upgraded from bare denials to repair
  guidance for both Claude Code and Codex CLI
- [x] Codex `UserPromptSubmit` now carries time, role, cwd, and git context
  (via shared `common-userpromptsubmit.sh codex`)
- [x] `model_auto_compact_token_limit =
  builtins.floor (codexContextWindow * 0.7)` autocompact at 70% (190,400
  tokens for gpt-5.x 272k window)
- [x] `tui.terminal_title = []` disables Codex terminal-title writes so tmux
  `pane_title` stays reserved for role identity (v0.117.0)
- [x] `codexScriptsDir` switched from `codex-*` glob to explicit `ln` list
  (commit `5fb7e44a`). The old glob would have expanded to literal
  `codex-*` after consolidation (no codex-prefixed scripts left) and
  failed the `runCommand` build. The explicit list also documents the
  Codex consumed surface in one place.
- [x] Removed `features.apps = false` on 2026-05-31 to allow Codex Apps by
  default again. It had been added 2026-05-03 after observing `codex_apps` MCP
  startup hangs in tmux panes; re-disable only if that hang returns as a
  measured first-display blocker.
- [x] `features.fast_mode = false` disables Codex Fast mode in the generated
  config. Added 2026-05-31 after confirming local Codex v0.135.0 still exposes
  the stable `fast_mode` feature and defaults it to enabled. This keeps the
  runtime aligned with explicit launch-time model and reasoning-effort pins
  instead of allowing `/fast` to swap behavior mid-session.
- [x] Removed redundant Codex feature overrides on 2026-05-31 after local
  Codex v0.135.0 confirmed `features.hooks` and `features.multi_agent` default
  to enabled. Removed stale `features.skills`; skills are configured through
  the top-level `skills` table, not a feature flag.
- [x] WAL checkpoint timer added 2026-05-07 after Codex logs WAL
  reached 32 GB on the Linux host (root/home at 98% used). One-shot manual
  `PRAGMA wal_checkpoint(TRUNCATE)` reclaimed the full 32 GB; the recurring
  timer keeps the WAL from growing back. On 2026-05-09, a separate full-disk
  incident showed `busy=1 log_pages=603 checkpointed=603`, where frames were
  checkpointed but active readers prevented truncation; the runbook now
  documents the emergency-only manual truncate exception with strict
  preconditions. On 2026-05-10, the Linux timer cadence moved to 30 minutes.
  Cross-platform: `systemd.user` timer on Linux,
  `launchd.agents` on Darwin, gated by `lib.mkIf` on `pkgs.stdenv.isLinux` /
  `isDarwin`. Symptom containment, not an upstream fix; inspection
  commands are archived with the runbook in the private vault.
- [x] (removed 2026-07-05) Linux `codex-storage-pressure-relief.timer` added
      2026-05-09 after a full-disk incident where `logs_2.sqlite-wal` reached
      about 37 GB and `tmux-a2a-postman` could not write state. The timer prunes
      disposable Codex temp data, prunes closed session JSONL older than 50 days
      while skipping open files, checkpoints `logs_2.sqlite`, and truncates a
      large fully-checkpointed WAL to zero after logging holder PIDs. The
      managed policy is storage relief only: process lifecycle stays outside the
      timer.

### 1.4. Pending Considerations

- [ ] Create prompts/ symlink to `../claude/commands/` if needed
- [ ] Create generate-config.sh for automated config.toml generation
- [x] Context7 MCP disabled; Context7 docs are handled through `ctx7` CLI plus
  the `find-docs` skill instead
- [x] Plan mode (`/plan`) - now stable and enabled by default (v0.94.0)
- [x] `command_attribution = "disable"` - co-author attribution disabled
  (v0.103.0)
- [ ] ~~PostToolUse Bash feedback heuristics~~ N/A — the
  `codex-posttooluse-review.sh` decorator that this would have extended
  was removed 2026-04-29 (commit `6add5abb`). Reintroducing it would
  be a deliberate new design decision, not a heuristic tweak.
- [ ] `code_mode` experimental feature - isolated coding workflow; watch
  for stabilization (v0.114.0)
- [ ] Disable bundled system skills config switch - useful if custom skills
  suffice for leaner sessions (v0.114.0)
- [ ] Permission profile config language - split filesystem/network sandbox
  policies for finer control in config.toml (v0.113.0)
- [x] Subagent support - multi-agent feature stabilized (v0.115.0); TOML agents
  are generated from `nix/home-manager/agents/subagents/*.md` plus
  `nix/home-manager/agents/subagents/metadata.nix` by
  `shared/install-manifest.nix` and installed by `codex/default.nix`
- [x] Status line permission/approval indicators - adopted after v0.131.0 added
  native TUI status items; generated `config.toml` now renders `permissions`
  and `approval-mode` next to model/context/version so `--yolo` and sandbox
  state stay visible in every pane.
- [ ] `openai_base_url` config override - custom API endpoint (v0.115.0)
- [ ] Smart Approvals guardian - route review requests through guardian
  subagent for reduced approval friction (v0.115.0)
- [ ] `codex exec resume --output-schema` - useful for future structured
  automation, but no current tmux-a2a-postman consumer needs resumed
  non-interactive JSON output.
- [ ] Optional: re-introduce a `Stop` handoff script if multi-day Codex
  resume becomes a regular workflow. Currently dropped because the
  Claude-side equivalent (`PreCompact` snapshot) was also dropped and
  the saved snapshots were rarely actionable. If reintroduced, the new
  script should land as a runtime-agnostic shared script (no prefix)
  with a runtime-arg shim, not as a fresh `codex-stop-save.sh` fork.

### 1.5. Not Adopting

- `personality` setting - keep default ("friendly"); no benefit from changing
- `log_dir` config - default log location is fine
- `tui.notifications_method` - keep default
- `CLAUDE_CODE_DISABLE_CRON` env - N/A for Codex CLI
- `approval_policy: on-failure` - deprecated (v0.102.0); not used in config
- `PreToolUse` / `PostToolUse` matcher patterns like `Write|Edit` - current
  Codex runtime only emits `Bash`, so these configs are misleading today
- `permissionDecision: "ask"` / `"allow"` and `updatedInput` in `PreToolUse` -
  current runtime parses them but does not enforce them
- PostToolUse Bash hooks at all - the previous `codex-posttooluse-review.sh`
  feedback decorator was removed 2026-04-29 (commit `6add5abb`); the agent
  reads command failures directly from stdout/stderr without a hook
  decoration. Keep the slot empty unless a load-bearing case appears.
- `AfterToolUse` hook - superseded by documented hooks engine
- `smart_approvals` - keep default behavior (v0.93.0)
- Plugin marketplace/share workflow - not used by this dotfiles-managed local
  harness; keep skills and agents installed through `shared/agent-skills.nix`
  and `shared/install-manifest.nix`
- App connector `default_tools_approval_mode = "writes"` - useful when
  read-only app calls should auto-run while write-like tools prompt, but this
  repo keeps Gmail, Drive, Calendar, and Slack at `prompt` because read access
  to private connector data is still sensitive
- Python SDK package/auth/turn APIs - useful for app-server automation, but no
  local harness script currently imports `openai_codex`
- `remote-control` / remote environments - no current daemon-managed remote
  executor workflow; keep local tmux-pane orchestration as the active surface
- `profile-v2` layered configs - generated Codex config remains the single
  managed base plus preserved project trust/hook state

### 1.6. Version Notes

- v0.144.4 (2026-07-14): Latest stable at review time; patch release with no
  user-facing changes. Local `codex --version` reported `codex-cli 0.144.4`.
- v0.144.3 (2026-07-13): Version-only release with no merged PR changes after
  v0.144.2.
- v0.144.2 (2026-07-13): Restored the previous Guardian auto-review policy,
  request format, and tool behavior after a prompting regression. No local
  config change.
- v0.144.0 (2026-07-09): Reviewed during the v0.144.4 pass. Relevant items:
  usage-limit reset-credit selection, new `writes` app approval mode,
  interactive MCP auth by default, runtime Codex auth for app-server hosts,
  global pnpm-install detection, Ultra reasoning concurrency warnings, Code
  Mode and Windows sandbox fixes, terminal-control sanitization, app auth
  refresh fixes, WebSocket proxy/custom CA preservation, faster review branch
  picking, plugin skill-loading speedups, and Bedrock model display updates.
  Kept app connector approvals at `prompt`.
- v0.143.0 (2026-07-08): Reviewed during the v0.144.4 pass. Relevant items:
  remote plugins enabled by default, system-proxy routing for authentication
  and Responses API traffic, `codex remote-control pair`, Bedrock GPT-5.6
  Sol/Terra/Luna plus `max` reasoning effort, MCP tool search by default,
  ChatGPT-hosted MCP session auth, app-server environment/thread/fork APIs,
  installer GitHub API rate-limit reduction, and the final persistent-log write
  reduction for the prior WAL-bloat incident. No local config change.
- v0.135.0 (2026-05-28): Reviewed release notes on 2026-05-31 after local
  `codex --version` reported `codex-cli 0.135.0`; upstream marked this as the
  latest stable release, with `rust-v0.136.0-alpha.1` newer but pre-release.
  Relevant items: richer `codex doctor` diagnostics, `/status` remote details,
  named permission profiles in `/permissions`, Vim mode text objects and
  configurable interruption binding, bundled patched zsh helper discovery,
  non-interactive installer mode, TUI markdown/table/rendering fixes, resume
  cwd fixes, and memory runtime state moved into its own SQLite database. No
  new harness feature was adopted beyond the user-requested `fast_mode`
  disable; the existing WAL timer remains because release notes do not claim a
  logs WAL fix.
- v0.134.0 (2026-05-26): Reviewed during the v0.135.0 follow-up window.
  Relevant items: local conversation-history search, `--profile` as the
  primary profile selector with legacy profile rejection, MCP per-server
  environment/OAuth improvements, connector schema preservation and compaction,
  parallel read-only MCP tools via `readOnlyHint`, richer extension/hook
  context including subagent identity, and remote/websocket reliability fixes.
  No local config change was needed; the generated config remains the managed
  base profile surface.
- v0.133.0 (2026-05-21): Reviewed during the v0.135.0 follow-up window.
  Relevant items: goals enabled by default with dedicated storage,
  foreground-style `codex remote-control` readiness/status behavior, permission
  profile list/inheritance/managed requirements work, plugin discovery list
  visibility, subagent/tool/turn lifecycle extension hooks, AGENTS loading
  reliability fixes, code-mode raw-output preservation, and packaged Codex
  runtime/archive work. No harness config change was adopted from this release.
- v0.132.0 (2026-05-21): Reviewed local release notes via GitHub releases
  after local `codex --version` reported `codex-cli 0.132.0`; npm `latest`
  also resolved to `0.132.0`. Relevant items: `codex exec resume
  --output-schema` for structured resumed automations, faster TUI startup,
  standard Codex auth for remote executor registration, original-resolution
  image fidelity in app-server turns, safer goal continuation stops, session
  picker paste/renamed-thread fixes, remote websocket keepalives, and versioned
  memory summaries. No additional config was adopted; the automation-specific
  `exec resume --output-schema`, remote executor registration, and Python SDK
  improvements are tracked as non-current harness surfaces.
- v0.131.0 (2026-05-21): Reviewed release notes while moving from the previous
  v0.130.0 review window. Adopted the new native TUI status-line `permissions`
  and `approval-mode` items in generated Codex config. Accepted `codex doctor`
  as a manual diagnostic command for support-ready config, auth, and runtime
  checks; no timer or activation hook was added. Other notable items were
  unified `@` mentions, plugin marketplace/share flow, remote-control daemon
  APIs, `openai-codex` Python SDK work, strict config parsing, and safer SQLite
  startup/recovery; these do not require additional local config today.
- v0.130.0 (2026-05-11): Reviewed local release notes via GitHub releases
  after local `codex --version` reported `codex-cli 0.130.0`. Relevant
  follow-up: v0.129.0 included `#20522 Alias codex_hooks feature as hooks`;
  local v0.130.0 warned that `[features].codex_hooks` was deprecated. The repo
  used `features.hooks = true` until v0.135.0 made `hooks` default-enabled.
  Other notable release items were plugin sharing/details, `codex
  remote-control`, thread pagination, selected-environment `view_image`, live
  app-server config refresh, and improved apply-patch diff tracking; no
  additional harness config change was adopted from those items.
- v0.128.0 (2026-05-03): Reviewed local release notes via GitHub releases.
  Relevant items: plugin workflows expanded, MCP/plugin cleanup fixes landed,
  `apps` remains a stable feature flag and can be disabled explicitly with
  `features.apps = false` if startup hangs return; permission-profile work is
  active but this repo still relies on current `--yolo`/config flow.
- v0.118.0 → v0.125.0 (2026-04-29): release notes not yet reviewed; the
  local install jumped while the previous review window stayed at
  v0.117.0. Superseded by the v0.128.0 review above.
- v0.117.0: `/title` terminal-title picker now works in both classic and
  app-server TUI, plugins become a first-class workflow, app-server TUI is now
  enabled by default, and legacy `artifact`, `read_file`, and `grep_files`
  handlers were removed
- v0.116.0: Local installed version at review time; official hooks docs still
  mark hooks as experimental and document current event support/limits at
  <https://developers.openai.com/codex/hooks>
- v0.115.0: Full-resolution image inspection via `view_image`, `js_repl`
  gains `codex.cwd`/`codex.homeDir` with cross-cell persistence, realtime
  WebSocket transcription mode + v2 handoff, v2 app-server filesystem RPCs
  with Python SDK, Smart Approvals guardian subagent for review routing,
  tool-search via Responses API with fallback, multi-agent feature stabilized,
  `wait_agent` tool rename, bubblewrap default Linux sandbox, `openai_base_url`
  config override
- v0.114.0: Experimental code mode (isolated coding), hooks engine
  (`SessionStart`/`Stop`), health endpoints (`/readyz`/`/healthz`) for
  app-server WebSocket, config to disable bundled system skills, handoff
  transcript context for turn continuity, `$` mention picker with
  category labels, Linux tmux segfault fix, approval persistence across
  turns, Python SDK v2 schema foundation
- v0.113.0: `request_permissions` tool (runtime permission requests), plugin
  marketplace + curated discovery + uninstall, app-server streaming exec with
  TTY/PTY, web search full tool config, permission profile config language,
  image gen saves to cwd, SQLite DB for logs, winget auto-update
- v0.112.0: `@plugin` mentions for direct plugin reference, permission profiles
  merged into per-turn sandbox, JS REPL binding persistence fix, SIGTERM
  graceful shutdown, bubblewrap userns hardening, macOS Seatbelt improvements
- v0.111.0: Fast mode enabled by default, TUI shows Fast/Standard mode,
  `js_repl` can import local `.js`/`.mjs` files, plugins reported to model
  at session start, app-server v2 MCP elicitation as structured request/response
- v0.110.0: Plugin system (skills/MCP/app connectors from config or
  marketplace), persisted `/fast` toggle, multi-agent TUI flow with approval
  prompts, workspace-scoped memory writes, Windows installer
- v0.107.0: Fork thread into sub-agents, realtime voice device selection,
  multimodal custom tool output, memories configurable
  (`codex debug clear-memories`)
- v0.104.0: `WS_PROXY`/`WSS_PROXY` env for websocket proxying,
  `ConfigChange` hook from app-server, command approval ID plumbing
- v0.103.0: Commit co-author attribution via `command_attribution` config,
  richer app details in listings
- v0.102.0: Unified permissions flow with TUI history, slash command to grant
  sandbox read access, customizable multi-agent roles, `model/rerouted`
  notification, `approval_policy: on-failure` deprecated
- v0.101.0: Bug fixes for memory and model resolution
- v0.100.0: Experimental JS REPL runtime, memory slash commands
  (`/m_update`, `/m_drop`), `ReadOnlyAccess` sandbox policy,
  `AfterToolUse` hook
- v0.99.0: `/statusline` command for TUI footer config, shell commands no
  longer interrupt in-flight turns, GIF/WebP image support, `AfterToolUse`
  hook added, security fix (RUSTSEC-2026-0009)
- v0.98.0: **GPT-5.3-Codex** model introduced, steer mode stable by default
  (Enter sends, Tab queues)
- v0.97.0: "Allow and remember" for MCP/App tools, live skill updates,
  `/debug-config` slash command, configurable `log_dir`
- v0.96.0: `unified_exec` enabled on all non-Windows platforms
- v0.95.0: `~/.agents/skills` personal skill loading, `/plan` accepts args
  and images, parallel shell tools, `CODEX_THREAD_ID` env injected
- v0.94.0: **Plan mode enabled by default**, `personality` config stable
  (default: friendly), skills from `.agents/skills`

## 2. Response Format (CHANGELOG)

```text
# Codex CLI vX.X.X 更新内容

## 新機能
- [機能名]: [説明]

## バグ修正
- [修正内容]

## 改善
- [改善内容]

## 破壊的変更
- [影響を受ける機能と移行方法]

---
Source: https://github.com/openai/codex/releases
```

## 3. Important Notes

- Codex CLI changelog is on the releases page, not CHANGELOG.md
- Use GitHub releases API to fetch release notes
- Always specify the version being referenced
- Link to official release page when available

## 4. Reference Links

- Codex CLI: <https://github.com/openai/codex>
- Codex hooks docs: <https://developers.openai.com/codex/hooks>
