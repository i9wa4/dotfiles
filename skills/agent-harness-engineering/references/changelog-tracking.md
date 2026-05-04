# Claude Code Changelog Tracking

Version history and optimization decision log for Claude Code configuration.
This reference preserves older review notes that support current
`agent-harness-engineering` decisions.

## 1. Not Adopting

- `showTurnDuration` - keep default (show duration)
- `reducedMotionMode` - keep default (animations enabled)
- Keybindings customization - use defaults
- Completion status reporting - no consumer for this output
- `CLAUDE_BASH_NO_LOGIN` - obsolete since v2.1.51 (auto-skip when snapshot
  available)
- `plansDirectory` - not needed
- `mcpToolSearch` - setting does not exist; `ENABLE_TOOL_SEARCH` env is the
  only mechanism (currently set to "auto:3")
- `background: true` in agent defs - UI-level background for Claude Code's own
  Agent tool; no benefit for tmux-a2a-postman (OS-level parallelism)
- Managed settings (plist/Registry) - enterprise MDM feature; solo Ubuntu user
- `InstructionsLoaded` hook - observability only, cannot inject context;
  existing `SessionStart` hook with `compact` matcher already handles reload
- `/loop` command - available since v2.1.71; no config needed
- `CLAUDE_CODE_DISABLE_CRON` env - cron scheduling useful for `/loop`; keep
  enabled
- Effort level simplification (v2.1.72) - low/medium/high with `/effort auto`;
  no config needed
- `autoMemoryDirectory` (v2.1.74) - auto-memory disabled via env; not applicable
- `modelOverrides` (v2.1.73) - not using Bedrock/Vertex/Foundry custom IDs
- `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` (v2.1.74) - no SessionEnd hooks
  configured
- `sandbox.failIfUnavailable` (v2.1.83) - runs with
  --dangerously-skip-permissions
- `CwdChanged`/`FileChanged` hooks (v2.1.83) - no direnv workflow needed
- `TaskCreated` hook (v2.1.84) - no workflow automation consumer
- `initialPrompt` agent frontmatter (v2.1.83) - not needed for current agents
- `CLAUDE_STREAM_IDLE_TIMEOUT_MS` (v2.1.84) - default 90s is adequate
- `allowedChannelPlugins` managed setting (v2.1.84) - not using channels
- `managed-settings.d/` drop-in directory (v2.1.83) - solo user, not enterprise
- `disableDeepLinkRegistration` (v2.1.83) - deep links are useful, keep enabled
- `CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK` (v2.1.83) - fallback is useful
- `allowRead` sandbox setting (v2.1.77) - not configuring sandbox read
  restrictions
- Superseded adaptive-thinking decision - an earlier 2026-04-08 review kept
  `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` unset. Current config now sets it to
  `"1"`; see `claude-code.md` Applied Optimizations for the active
  decision. The earlier rationale was based on HN discussion of Feb 2026 Claude
  Code updates (<https://news.ycombinator.com/item?id=47664442>). Boris
  (bcherny, Anthropic Claude Code team) confirmed Opus 4.6 ships with
  adaptive thinking where the model self-allocates reasoning budget per
  task, with medium as the default effort ceiling for non-Enterprise users.
  Some HN commenters reported that setting `=1` improved "lazy" behavior on
  complex engineering tasks by forcing a fixed high budget via
  `MAX_THINKING_TOKENS`. However, this setup already boosts effort to
  `high` at session startup, which raises adaptive's ceiling to match the
  Team/Enterprise default that Anthropic formalized in v2.1.94 (default effort
  changed from medium to high for API-key/Bedrock/Vertex/Foundry/Team/Enterprise
  users). This note is retained for historical context only.
- `CLAUDE_CODE_USE_MANTLE` (v2.1.94) - not using Amazon Bedrock via Mantle
- Default effort change to high (v2.1.94) - applies only to API-key/
  Bedrock/Vertex/Foundry/Team/Enterprise; solo Pro/Max user not
  auto-affected, but this validates the adaptive-thinking decision above
  (Anthropic shipped high as the default for heavy users, aligning with
  the startup `/effort high` pattern already in use)
- `hookSpecificOutput.sessionTitle` for UserPromptSubmit (v2.1.94) -
  potential future use for dynamic tmux pane titles; not currently needed
- `keep-coding-instructions` plugin output style frontmatter (v2.1.94) -
  no plugin output styles in use
- `forceRemoteSettingsRefresh` (v2.1.92) - enterprise managed settings;
  solo user
- Bedrock interactive setup wizard (v2.1.92) - not using Bedrock
- `_meta["anthropic/maxResultSizeChars"]` MCP result override (v2.1.91) -
  no large-result MCP needs currently
- `disableSkillShellExecution` (v2.1.91) - many installed skills rely on
  inline shell execution (site2skill, running-dbt-commands, etc.);
  disabling would break them
- Plugin `bin/` executables (v2.1.91) - no plugins used
- `/powerup` interactive lessons (v2.1.90) - user-invokable, no config
- `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` (v2.1.90) - no plugins
- `"defer"` PreToolUse hook decision (v2.1.89) - no headless `-p --resume`
  workflow currently
- `PermissionDenied` hook (v2.1.89) - auto mode classifier not in use
  (strict deny list handles permissions deterministically)
- `CLAUDE_CODE_NO_FLICKER=1` (v2.1.89) - consider later if rendering
  glitches observed; see pending considerations in SKILL.md section 11.2
- `MCP_CONNECTION_NONBLOCKING=true` (v2.1.89) - not running `-p` mode

## 2. Version Notes

- v2.1.94: **Default effort level changed from medium to high** for
  API-key/Bedrock/Vertex/Foundry/Team/Enterprise users (control via
  `/effort`), `CLAUDE_CODE_USE_MANTLE=1` for Amazon Bedrock via Mantle,
  `hookSpecificOutput.sessionTitle` for UserPromptSubmit hooks,
  `keep-coding-instructions` plugin output style frontmatter, plugin skill
  `name` override (stable across install methods), rate-limit long
  Retry-After surface fix, Console login keychain-locked surface fix, many
  bugfixes (Slack MCP header, plugin hooks, scrollback duplicates, SDK
  interrupted resume, CJK multibyte in stream-json). Related: HN
  discussion <https://news.ycombinator.com/item?id=47664442>
- v2.1.92: `forceRemoteSettingsRefresh` policy (fail-closed remote
  settings fetch), interactive Bedrock setup wizard, per-model `/cost`
  breakdown, interactive `/release-notes`, Remote Control hostname
  session prefix, prompt-cache-expired footer hint, **removed `/tag` and
  `/vim` commands** (vim toggle moved to `/config` → Editor mode), Linux
  sandbox ships `apply-seccomp` in both npm and native builds, Write tool
  60% faster on files with tabs/`&`/`$`, subagent "Could not determine
  pane count" fix
- v2.1.91: MCP `_meta["anthropic/maxResultSizeChars"]` up to 500K,
  `disableSkillShellExecution` setting, multi-line prompts in
  `claude-cli://open?q=` deep links, plugin `bin/` executables,
  `/claude-api` skill improved, Edit tool shorter `old_string` anchors,
  transcript chain-break on `--resume` fix, `permissions.defaultMode:
  "auto"` schema validation, Bun `stripAnsi` perf
- v2.1.90: **`/powerup` interactive lessons**,
  `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` env, `.husky`
  protected dir, **`--resume` prompt-cache miss fix** (regression since
  v2.1.69), auto mode respects explicit user boundaries, SSE transport
  O(n) from O(n^2), PowerShell tool hardening (trailing `&` bypass,
  `-ErrorAction Break` hang, archive TOCTOU, parse-fail deny-rule
  degradation), removed `Get-DnsClientCache`/`ipconfig /displaydns` from
  auto-allow
- v2.1.89: **`"defer"` PreToolUse hook decision**,
  `CLAUDE_CODE_NO_FLICKER=1` env, **`PermissionDenied` hook event**
  (fires after auto mode classifier denials), named subagents in `@`
  mention typeahead, `MCP_CONNECTION_NONBLOCKING=true` for `-p` mode,
  auto-mode denied notifications in `/permissions` Recent tab,
  **symlink resolution for Edit/Read allow rules** (security),
  StructuredOutput schema cache 50% failure fix, **autocompact thrash
  loop detection**, **nested CLAUDE.md re-injection fix** (prompt cache),
  prompt-cache tool-schema byte-drift fix, `cleanupPeriodDays: 0` now
  rejected with validation error, hook output >50K saved to disk with
  file path + preview, **`showThinkingSummaries` must now be set
  explicitly** (thinking summaries no longer generated by default in
  interactive sessions), `TaskCreated` hook documented, Devanagari
  combining marks rendering, Shift+Enter on Windows Terminal Preview
  1.25, `/buddy` April 1st egg
- v2.1.87: Fixed Cowork Dispatch message delivery
- v2.1.86: `.jj`/`.sl` VCS exclusion, Read tool compact line-number format and
  deduplication, `@` file mention token reduction (no JSON escaping), prompt
  cache hit rate improvement for Bedrock/Vertex/Foundry, skill descriptions
  capped at 250 chars, `/skills` alphabetical sort, multiple resume/streaming
  fixes
- v2.1.85: Conditional `if` field for hooks (permission rule syntax), MCP
  `CLAUDE_CODE_MCP_SERVER_NAME`/`CLAUDE_CODE_MCP_SERVER_URL` env for
  headersHelper, PreToolUse hooks can satisfy `AskUserQuestion` via
  `updatedInput`, `/compact` context-exceeded fix, many plugin/MCP fixes
- v2.1.84: PowerShell tool (Windows opt-in), `TaskCreated` hook,
  `rules`/`skills` `paths:` YAML list of globs, MCP tool descriptions capped at
  2KB, `CLAUDE_STREAM_IDLE_TIMEOUT_MS` env, `allowedChannelPlugins` managed
  setting, idle-return prompt after 75+ min, WorktreeCreate HTTP hook support,
  `ANTHROPIC_CUSTOM_MODEL_OPTION` env
- v2.1.83: `managed-settings.d/` drop-in directory, `CwdChanged`/`FileChanged`
  hooks, `sandbox.failIfUnavailable`, `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`,
  transcript search (`/` in Ctrl+O), `Ctrl+X Ctrl+E` external editor alias,
  `initialPrompt` agent frontmatter, `chat:killAgents`/`chat:fastMode`
  rebindable, `TaskOutput` deprecated (use Read), Ctrl+B moved to Ctrl+X
  Ctrl+K, WebFetch `Claude-User` identification, many memory/perf fixes
- v2.1.81: `--bare` flag for scripted `-p` calls, `--channels` permission relay,
  worktree resume on session resume, MCP OAuth CIMD support
- v2.1.80: `rate_limits` in statusline scripts, `effort` frontmatter for
  skills/commands, `source: 'settings'` plugin marketplace source,
  `--channels` research preview, `--resume` parallel tool results fix
- v2.1.79: `--console` flag for `claude auth login`, `/config` show turn
  duration toggle, `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` startup fix,
  `SessionEnd` hooks not firing on `/resume` fix
- v2.1.78: `StopFailure` hook event, `${CLAUDE_PLUGIN_DATA}` variable,
  `effort`/`maxTurns`/`disallowedTools` agent frontmatter, line-by-line response
  streaming, `includeGitInstructions` fully suppresses git status fix,
  `deny: ["mcp__servername"]` tool removal fix, sandbox `allowWrite` absolute
  path fix, security fix (silent sandbox disable warning)
- v2.1.77: 64k default / 128k max output tokens for Opus 4.6 / Sonnet 4.6,
  `allowRead` sandbox setting, `/copy N` index arg, "Always Allow" compound
  bash fix, PreToolUse `allow` bypassing deny rules security fix,
  `--resume` transcript truncation race fix, Write tool CRLF conversion fix,
  memory growth fix (progress messages surviving compaction), Agent `resume`
  parameter removed (use `SendMessage`)
- v2.1.75: 1M context for Opus 4.6 (Max/Team/Enterprise), `/color` command,
  session name on prompt bar, memory file timestamps, hook source display in
  permission prompts, token estimation over-counting fix, Windows managed
  settings fallback removed (breaking change)
- v2.1.74: `autoMemoryDirectory` setting, `/context` actionable suggestions,
  streaming API memory leak fix, managed policy `ask` rules bypass fix,
  agent frontmatter `model:` now accepts full model IDs,
  `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` env, RTL text rendering fix
- v2.1.73: `modelOverrides` setting for custom provider model IDs,
  `/output-style` deprecated (use `/config`), CPU freeze fix for complex
  bash permission prompts, skill directory deadlock fix, Bash tool output
  loss fix with concurrent sessions, default Opus on Bedrock/Vertex changed
  to 4.6, SessionStart hooks double-fire on resume fix
- v2.1.72: `/copy` write-to-file (`w` key), `/plan` description arg,
  `ExitWorktree` tool, `CLAUDE_CODE_DISABLE_CRON` env, bash auto-approval
  expanded (lsof, pgrep, tput, ss, fd, fdfind), `model` param on Agent tool
  restored, effort simplified to low/medium/high, CLAUDE.md HTML
  comments hidden when auto-injected, prompt cache fix (up to 12x savings),
  many memory/performance improvements, Sonnet 4.5 auto-migrated to 4.6
- v2.1.71: `/loop` recurring prompt command (e.g. `/loop 5m check deploy`),
  cron scheduling tools, `voice:pushToTalk` rebindable keybinding, stdin
  freeze fix in long sessions, background agent completion path fix
- v2.1.70: Remote Control poll rate cut 300x (once/10min while connected),
  VSCode native MCP management dialog, compaction preserves images for cache
  reuse, skill re-injection on `--resume` fix (~600 tokens saved)
- v2.1.69: `InstructionsLoaded` hook, `includeGitInstructions` setting +
  `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` env, `/remote-control` custom name
  arg, `${CLAUDE_SKILL_DIR}` variable for skills, `agent_id`/`agent_type` in
  hook events, Voice STT 20 languages, security fix (nested skill discovery
  from gitignored dirs), trust dialog fix for `.mcp.json`
- v2.1.68: Opus 4.6 defaults to medium effort for Max/Team; "ultrathink"
  re-introduced for high effort; Opus 4/4.1 removed from first-party API
- v2.1.66: Reduced spurious error logging
- v2.1.63: `/simplify` and `/batch` bundled commands, HTTP hooks,
  `ENABLE_CLAUDEAI_MCP_SERVERS=false` env, project configs shared across
  worktrees, "Always copy full response" for `/copy`, many memory leak fixes,
  `/clear` now resets cached skills
- v2.1.62: Fixed prompt suggestion cache regression
- v2.1.61: Fixed concurrent config writes on Windows
- v2.1.59: Auto-memory saving to auto-memory (manage with `/memory`), `/copy`
  command for code block selection, smarter "always allow" prefix suggestions
  for compound bash commands, config file corruption fix (multi-instance),
  MCP OAuth token refresh race condition fix
- v2.1.58: Remote Control expanded to more users
- v2.1.56: VS Code fixed "command 'claude-vscode.editor.openLast' not found"
  crashes (another cause)
- v2.1.55: BashTool EINVAL error fix on Windows
- v2.1.53: UI flicker fix, bulk agent kill fix, graceful shutdown fix, multiple
  Windows/WebAssembly crash fixes
- v2.1.52: VS Code extension crash fix on Windows
- v2.1.51: `claude remote-control` subcommand, BashTool auto-skips login shell
  (replaces `CLAUDE_BASH_NO_LOGIN=true`), tool results persisted at 50K chars
  (was 100K), **security fix for `statusLine`/`fileSuggestion` hooks** (require
  workspace trust), managed settings via macOS plist/Windows Registry,
  `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` env, custom npm registries for plugins,
  `/model` picker shows human-readable labels
- v2.1.50: WorktreeCreate/WorktreeRemove hooks, `isolation: worktree` in agent
  defs, `claude agents` CLI command, `CLAUDE_CODE_DISABLE_1M_CONTEXT` env,
  Opus 4.6 fast mode now has 1M context, multiple memory leak fixes
- v2.1.49: `--worktree` flag, `isolation: worktree` for subagents,
  `background: true` for agents, Ctrl+F kills background agents,
  `ConfigChange` hook event, Sonnet 4.5 1M context removed from Max plan,
  `disableAllHooks` managed settings hierarchy fix
- v2.1.47: `last_assistant_message` in Stop hooks, `chat:newline` keybinding,
  `added_dirs` in statusline JSON, config backups moved to `~/.claude/backups/`,
  **plan mode lost after compaction fix**, bash permission classifier
  hallucination fix, VS Code plan preview auto-update
- v2.1.46: claude.ai MCP connectors support
- v2.1.45: **Claude Sonnet 4.6**, `spinnerTipsOverride` setting,
  Agent Teams Bedrock/Vertex fix, macOS sandbox temp file fix
- v2.1.44: Auth refresh error fix
- v2.1.43: **Fixed AWS auth refresh hanging indefinitely** (3-min timeout),
  Vertex/Bedrock fixes
- v2.1.42: Startup performance improvement, prompt cache hit rate improvement
- v2.1.41: Guard against nested Claude Code sessions, FileReadTool hang fix,
  MCP image content crash fix, proactive ticks in plan mode fix
- v2.1.39: **Fixed process hanging after session close**, terminal rendering
  performance, fatal error display fix
- v2.1.38: VS Code scroll regression fix, Tab key autocomplete fix, heredoc
  command smuggling prevention
- v2.1.37: /fast immediately available after /extra-usage
- v2.1.36: Fast mode for Opus 4.6
- v2.1.34: **Sandbox bypass vulnerability fixed** (security), agent teams crash
  fix
- v2.1.33: TeammateIdle/TaskCompleted hooks, agent memory frontmatter,
  Task(agent_type) restrictions, tmux agent sessions fix
- v2.1.32: **Claude Opus 4.6 available**, automatic memory, agent teams research
  preview, skills auto-load from --add-dir, Bash template literal fix
- v2.1.31: PDF lock fix, sandbox error fix, system prompt improvement for
  dedicated tools
- v2.1.30: Read tool `pages` param for PDFs, `/debug` command, MCP OAuth
  pre-configured credentials, reduced motion mode
- v2.1.29: SessionStart hook saved_hook_context performance fix
- v2.1.27: --from-pr flag, auto PR-session linking, debug log improvements
- v2.1.23: spinnerVerbs setting, terminal rendering perf, mTLS/proxy fix
- v2.1.21: Zenkaku number input (JP IME), auto-compact timing fix, task ID
  reuse fix
- v2.1.20: PR review status indicator, --add-dir CLAUDE.md loading, TaskUpdate
  delete, config backup rotation, background agent permission prompt
- v2.1.19: CLAUDE_CODE_ENABLE_TASKS env, $ARGUMENTS[0] syntax, skill
  approval change
- v2.1.18: Customizable keybindings (/keybindings command)
- v2.1.16: New task management system with dependency tracking
- v2.1.15: npm deprecation notice, React Compiler UI perf, MCP stdio timeout
  fix
- v2.1.14: Bash history autocomplete, plugin pinning to git SHA, memory fixes
- v2.1.10: Setup hook, OAuth URL copy shortcut, heredoc template literal fix
- v2.1.9: plansDirectory, auto:N for MCP, PreToolUse additionalContext
- v2.1.7: keybindings.json, showTurnDuration, MCP tool search auto mode
- v2.1.3: Merged slash commands and skills
- v2.1.0: language setting, skill hot-reload, context: fork

---

Last updated: 2026-04-09
