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
  only override mechanism. Current config sets `ENABLE_TOOL_SEARCH=auto` so
  Claude Code upfront-loads MCP tools while they fit the default threshold, then
  defers/searches only when the tool surface grows beyond that threshold.
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
- `CLAUDE_CODE_FORCE_SYNC_OUTPUT=1` (v2.1.129) - terminal auto-detection works
  for our Alacritty/tmux setup; only needed on Emacs `eat` and similar
- `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` (v2.1.129) - claude-code binary
  is Nix-managed via `inputs.llm-agents`; package-manager auto-update would
  fight the flake pin
- `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` (v2.1.129) - using direct
  Anthropic, no gateway
- `--plugin-url <url>` (v2.1.129) - no plugins in use
- `skillOverrides` setting (v2.1.129) - all skills are intentionally
  installed via `shared/agent-skills.nix`
- `themes`/`monitors` under plugin `experimental` (v2.1.129) - not authoring
  plugins
- PowerShell tool features and `CLAUDE_CODE_USE_POWERSHELL_TOOL` /
  `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY` (v2.1.126, v2.1.142,
  v2.1.143) - Linux-only host
- `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` (v2.1.141) - no plugins
- `ANTHROPIC_WORKSPACE_ID` (v2.1.141) - not using workload identity
  federation
- `terminalSequence` hook output (v2.1.141) - no use case yet for desktop
  notifications / bells from hooks
- `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` (v2.1.136) - feedback survey
  already disabled globally via `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=true`
- `settings.autoMode.hard_deny` (v2.1.136) - not using auto mode; deny-list
  is the strict permission boundary
- `sandbox.bwrapPath` / `sandbox.socatPath` managed settings (v2.1.133) -
  default bubblewrap/socat from nixpkgs are on PATH
- `parentSettingsBehavior` (v2.1.133) - solo-user, no SDK `managedSettings`
  tier
- `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` (v2.1.142) - fast mode is
  hard-disabled, so the Opus 4.6 vs 4.7 fast-mode pin is moot
- `worktree.bgIsolation: "none"` (v2.1.143) - worktrees ARE practical here;
  keep default `auto` isolation
- `claude project purge` (v2.1.126) - one-shot CLI; no config to adopt,
  remember as a manual cleanup command
- `sandbox.credentials` (v2.1.187) - promising for sandboxed sessions, but this
  harness currently relies on bypass-permissions plus shared deny hooks. Do not
  present it as active protection until we intentionally design a sandbox path.
- `autoMode.classifyAllShell` and denial transcript details (v2.1.193) - not
  using auto mode; deterministic shared Bash deny remains the policy authority.
- `OTEL_LOG_ASSISTANT_RESPONSES` (v2.1.193) - telemetry is disabled in
  `claude/default.nix`. If telemetry and prompt logging are re-enabled later,
  set `OTEL_LOG_ASSISTANT_RESPONSES=0` unless response-content logging is
  explicitly desired.
- `respondToBashCommands: false` (v2.1.186) - possible compatibility knob for
  the changed `!` Bash behavior, but no current harness flow uses interactive
  `!` commands enough to force the old context-only behavior.
- `Tool(param:value)` permission syntax (v2.1.178) - future policy option for
  parameterized Agent/Tool restrictions; no current rule requires it.
- `fallbackModel` (v2.1.166) - defer because launch-time model pinning should
  make overload/model failures visible instead of silently swapping behavior.
- `--safe-mode` / `CLAUDE_CODE_SAFE_MODE` (v2.1.169) - troubleshooting path
  only, not a default.
- `disableBundledSkills` / `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` (v2.1.169) -
  leave bundled skills visible until there is a concrete collision or context
  pressure problem.
- `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` (v2.1.195) and
  `wheelScrollAccelerationEnabled` (v2.1.174) - UI preference only.
- `enforceAvailableModels` (v2.1.175) and org model restrictions (v2.1.187) -
  enterprise/org policy surfaces; solo local config does not manage them.

## 2. Version Notes

- v2.1.195: `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` for fullscreen mouse
  click/drag/hover opt-out; **hook matcher fix for hyphenated identifiers**
  now exact-matches (`mcp__brave-search__.*` needed for all tools from such a
  server); plugin consent fixes; many background-agent visibility/restart and
  Remote startup improvements.
- v2.1.193: `autoMode.classifyAllShell`; auto-mode denial reasons now appear in
  transcript/toast/recent denials; `claude_code.assistant_response` OTEL log
  event, redacted unless `OTEL_LOG_ASSISTANT_RESPONSES=1` and otherwise tied to
  prompt logging; Bash-mode path autocomplete; MCP auth startup notice; idle
  background shell memory-pressure reaping.
- v2.1.187: `sandbox.credentials` setting; org model restrictions shown in
  model picker/flags/env; remote MCP tool calls abort after idle timeout instead
  of hanging; many background job, worktree, and Remote Control reliability
  fixes.
- v2.1.186: `claude mcp login/logout`; `!` Bash commands now trigger an
  assistant response by default (`respondToBashCommands: false` restores
  context-only behavior); background subagent permission prompts surface in the
  main session; `/review <pr>` uses the `/code-review medium` engine.
- v2.1.183: auto-mode safety blocks destructive git/IaC commands unless asked;
  warnings when requested models are deprecated or remapped;
  `attribution.sessionUrl` can omit web/Remote session links; several scheduled
  and webhook notification and background task fixes.
- v2.1.178: Agent teams no longer use `TeamCreate`/`TeamDelete`;
  `Tool(param:value)` permission-rule syntax; nested `.claude/skills` loading
  and local precedence rules; auto mode evaluates subagent spawns before launch.
- v2.1.176: `footerLinksRegexes`; Bedrock credential cache follows expiration;
  hook `if` path conditions for Read/Edit/Write fixed; `/cd` and background
  session git-branch state fixes.
- v2.1.172: subagents can spawn nested subagents up to 5 levels; many model
  availability, 1M context, wildcard permission, Remote Control, and long
  conversation performance fixes.
- v2.1.169: self-hosted runner `post-session` hook; `--safe-mode` /
  `CLAUDE_CODE_SAFE_MODE`; `/cd`; `disableBundledSkills`;
  `claude agents --json --all` plus `id`/`state`; managed MCP policy
  enforcement fixes and background session worktree guidance.
- v2.1.166: `fallbackModel`; glob support in deny rule tool-name position;
  cross-session messaging no longer carries user authority; thinking can be
  disabled on thinking-default models; fallback retry on unexpected
  non-retryable API errors.
- v2.1.162: `claude agents --json` adds `waitingFor`; `/effort` persistence
  confirmation; WebFetch deny/ask/allow precedence over preapproved domains;
  wider `claude agents` status rendering; failed background sends are queued.
- v2.1.160: prompts before writes to shell startup files and execution-granting
  build config files; improved background teardown; **removed
  `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`**.
- v2.1.157: plugins in `.claude/skills` auto-load; `claude plugin init`;
  `settings.json` `agent` honored for `claude agents`; `EnterWorktree` can
  switch between Claude-managed worktrees; tool-decision telemetry can include
  tool parameters.
- v2.1.154: Opus 4.8, dynamic workflows, lean system prompt default, background
  shell sessions from `claude agents`, streaming tool execution always enabled,
  stdio MCP subprocesses receive `CLAUDE_CODE_SESSION_ID` and `CLAUDECODE=1`;
  several security/permission fixes including `$HOME` removal detection and
  background subagent worktree isolation.
- v2.1.153: status line commands receive `COLUMNS`/`LINES`; `claude agents`
  autocomplete includes native slash commands and bundled skills; subagent MCP
  policy fixes; background sessions avoid stale daemons; `/model` default-save
  keybinding changed.
- v2.1.152: `/code-review --fix`; skills and slash commands can set
  `disallowed-tools`; `/reload-skills`; SessionStart can reload skills or set
  title; `MessageDisplay` hook; auto mode no longer requires opt-in consent.
- v2.1.149: `/usage` breakdown by skills/subagents/plugins/MCP; markdown task
  checkboxes render; **PowerShell permission bypass fix**, **sandbox worktree
  write allowlist fix**, parser stale-variable fix, and `find` macOS
  file-table crash fix.
- v2.1.147: pinned background sessions; `/simplify` renamed to `/code-review`
  with bug-finding review semantics; auto-updater and diff performance
  improvements; many PowerShell, MCP pagination, background permission, CJK,
  paste, and plugin count fixes.
- v2.1.145: `claude agents --json` for scriptable session listing, OTEL
  `agent_id`/`parent_agent_id` on `claude_code.tool` spans with corrected
  subagent span parenting, status line JSON gains GitHub repo + PR info,
  `/plugin` Discover/Browse preview a plugin's contributed
  commands/agents/skills/hooks/MCP/LSP, Stop/SubagentStop hook input
  includes `background_tasks` + `session_crons`, **security fix:
  permission-prompt bypass for bare variable assignments to
  non-allowlisted env vars in Bash commands**, MCP prompt slash command
  errors now name the missing argument, Read tool returns a truncated
  "PARTIAL view" instead of a hard error on token-limit overflow
- v2.1.144: `/resume` lists background sessions (marked `bg`),
  background subagent completion notifications carry elapsed duration,
  `/model` becomes session-scoped (press `d` for default), `/extra-usage`
  renamed to `/usage-credits` (old name still works), startup hang on
  unreachable `api.anthropic.com` cut from 75s to 15s, many background-
  session Edit/Write/scroll/PR-state fixes, Skill tool no longer errors
  in headless mode, MCP `tools/list` pagination fix (servers no longer
  silently drop tools), `/branch` worktree fix
- v2.1.143: **`worktree.bgIsolation: "none"` setting** to skip background-
  session worktree isolation, PowerShell tool now passes `-ExecutionPolicy
  Bypass` (opt out via `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY=1`),
  `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` env (default 8) prevents runaway Stop
  hooks, `claude agents` accepts `--add-dir`/`--settings`/`--mcp-config`/
  `--plugin-dir`/`--permission-mode`/`--model`/`--effort`/
  `--dangerously-skip-permissions`, worktree cleanup no longer falls back
  to `rm -rf` (safety), `NO_COLOR`/`FORCE_COLOR` in `settings.json` `env`
  applies to subprocesses only (not Claude's own UI), background sessions
  preserve model/effort across idle wake
- v2.1.142: **Fast mode now uses Opus 4.7 by default** (was Opus 4.6); set
  `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` to pin fast mode to Opus 4.6.
  Plugins with a root-level `SKILL.md` and no `skills/` subdirectory are
  now surfaced as a skill, many background-session and plugin-cache fixes
- v2.1.141: `terminalSequence` field in hook JSON output (desktop
  notifications/titles/bells without controlling terminal),
  `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` env, `ANTHROPIC_WORKSPACE_ID` for
  workload identity federation, `claude agents --cwd <path>` to scope
  session list, `/feedback` can include recent sessions, rewind menu gets
  "Summarize up to here", background-agent stale-detection storm fix
  after macOS App Nap
- v2.1.140: Agent tool `subagent_type` matching is now case- and
  separator-insensitive (e.g. `"Code Reviewer"` -> `code-reviewer`),
  `/loop` no longer schedules redundant wakeups when background tasks
  already notify, settings hot-reload fix for symlinked settings files
- v2.1.139: **Agent view (Research Preview): `claude agents` lists every
  Claude Code session**, **`/goal` command** (set completion condition,
  Claude works across turns until met), `/scroll-speed` command,
  `claude plugin details <name>`, transcript view nav (`?` shortcuts,
  `{`/`}` between user prompts), **hook `args: string[]` exec form**
  (spawns command directly without a shell), **hook `continueOnBlock`
  for `PostToolUse`** (feed rejection reason back to Claude),
  **MCP stdio servers receive `CLAUDE_PROJECT_DIR`**, **`Skill(name *)`
  permission rules now match as prefix**, Remote Control / `/schedule` /
  claude.ai MCP connectors / notification preferences are now disabled
  when `ANTHROPIC_API_KEY` / `apiKeyHelper` / `ANTHROPIC_AUTH_TOKEN` is
  set (even with claude.ai login)
- v2.1.136: `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` env,
  `settings.autoMode.hard_deny` for unconditional auto-mode classifier
  blocks, plan mode now blocks file writes even when a matching `Edit(...)`
  allow rule exists, MCP OAuth refresh-token concurrency fix (no more
  daily re-auth with many remote servers)
- v2.1.133: **`worktree.baseRef` setting (`fresh` | `head`)** for
  `--worktree` / `EnterWorktree` / agent-isolation worktrees; **default
  `fresh` flips `EnterWorktree` base back to `origin/<default>`** (was
  local HEAD since v2.1.128) -- set `worktree.baseRef: "head"` to keep
  unpushed commits in new worktrees. `sandbox.bwrapPath`,
  `sandbox.socatPath` managed settings (Linux/WSL),
  `parentSettingsBehavior` admin-tier key. **Hooks now receive
  `effort.level` in JSON input and `$CLAUDE_EFFORT` env var**, Bash tool
  commands can read `$CLAUDE_EFFORT`. Edit/Write allow-rule fix for
  `C:\`/`/` drive-root scoping
- v2.1.132: `CLAUDE_CODE_SESSION_ID` env in Bash tool subprocess
  (matches hook `session_id`), `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`
  to opt out of fullscreen alt-screen renderer, graceful shutdown on
  external SIGINT (terminal modes restored), `--permission-mode` flag
  fix on resumed plan-mode sessions, `/effort` picker now reflects
  `CLAUDE_CODE_EFFORT_LEVEL` override, MCP `tools/list` failure now
  shows "connected · tools fetch failed"
- v2.1.131: VS Code Windows activation fix, Mantle `x-api-key` header fix
- v2.1.129: `--plugin-url <url>` flag for one-shot plugin install from a
  zip URL, `CLAUDE_CODE_FORCE_SYNC_OUTPUT=1` for terminals where sync-output
  auto-detection misses, `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` for
  Homebrew/WinGet, plugin manifests: `themes` and `monitors` move under
  `"experimental": { ... }`, `/v1/models` gateway discovery now opt-in via
  `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`, Ctrl+R searches all
  projects by default (Ctrl+S narrows), `skillOverrides` setting now works
  (`off` | `user-invocable-only` | `name-only`)
- v2.1.128: `EnterWorktree` now creates from local HEAD (later reverted by
  v2.1.133 `fresh` default), MCP `workspace` is now a reserved server name,
  reconnecting MCP servers summarize re-announced tools by server prefix
  (less spam), `/mcp` shows tool count and flags 0-tool servers,
  subprocesses no longer inherit `OTEL_*` env (OTEL-instrumented Bash apps
  no longer pick up the CLI's OTLP endpoint), parallel shell tool calls:
  failing read-only command no longer cancels siblings
- v2.1.126: **`claude project purge [path]`** deletes all Claude Code
  state for a project (transcripts, tasks, file history, config entry);
  supports `--dry-run` / `-y` / `-i` / `--all`. **Security:
  `allowManagedDomainsOnly` / `allowManagedReadPathsOnly` were ignored
  when a higher-priority managed-settings source lacked a `sandbox` block
  -- now applied correctly**. `--dangerously-skip-permissions` now bypasses
  prompts for writes to `.claude/`, `.git/`, `.vscode/`, shell config
  files (catastrophic removal commands still prompt). `claude auth login`
  accepts OAuth code paste when browser callback can't reach localhost
  (WSL2, SSH, containers). `claude_code.skill_activated` OTEL event gains
  `invocation_trigger` attribute. **Read tool removed the per-file
  malware-assessment reminder** that caused spurious refusals on legacy
  models
- v2.1.123: OAuth 401 retry-loop fix when
  `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` is set
- v2.1.122: `ANTHROPIC_BEDROCK_SERVICE_TIER` env (`default` | `flex` |
  `priority`), `/resume` accepts a PR URL to find the session that created
  it (GitHub, GHE, GitLab, Bitbucket), `/mcp` shows claude.ai connectors
  hidden by duplicate manual servers, OTel `api_request`/`api_error`
  numeric attributes now emitted as numbers
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
  `added_dirs` in statusline JSON, config backups relocated to a dedicated
  `backups/` directory under the Claude config root,
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

Last updated: 2026-05-21
