# Changelog Tracking

Version history and optimization decision log for Claude Code configuration.

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

## 2. Version Notes

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

Last updated: 2026-03-13
