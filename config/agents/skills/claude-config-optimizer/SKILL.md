---
name: claude-config-optimizer
description: |
  Claude Code config optimization skill.
  Use when:
  - Editing CLAUDE.md, rules/, skills/, agents/, commands/
  - User asks about config best practices
  - Checking optimization status
  - User says "claude code changelog" or "claude code updates"
  - User asks about new features or breaking changes in Claude Code
---

# Claude Config Optimizer Skill

Rules and tracking for Claude Code configuration optimization.

## 1. Config File Location

Config is managed declaratively via Nix (`programs.claude-code` home-manager module).

Source of truth:

- @~/ghq/github.com/i9wa4/dotfiles/nix/home-manager/claude-code.nix
- @~/ghq/github.com/i9wa4/dotfiles/config/agents/

| Destination               | Source                             | Managed by         |
| ----------------------    | ------------------------------     | ------------------ |
| `~/.claude/settings.json` | Generated from Nix attributes      | claude-code.nix    |
| `~/.claude/CLAUDE.md`     | `config/agents/AGENTS.md`          | claude-code.nix    |
| `~/.claude/rules/`        | `config/agents/rules/`             | claude-code.nix    |
| `~/.claude/agents/`       | `config/agents/subagents/`         | claude-code.nix    |
| `~/.claude/scripts/`      | `config/agents/scripts/`           | claude-code.nix    |
| `~/.claude/skills/`       | Multiple flake inputs + local      | agent-skills.nix   |
| MCP servers               | `nix/home-manager/mcp-servers.nix` | claude-code.nix    |

## 2. Fetch CHANGELOG

Use `gh` command to fetch the latest CHANGELOG:

```sh
FILE=$(mkoutput --dir tmp --label claude-code-changelog)
gh api repos/anthropics/claude-code/contents/CHANGELOG.md \
  --jq '.content' | base64 -d > "$FILE"
```

Then read the file to analyze.

## 3. CHANGELOG Operations

### 3.1. Latest Release Summary

1. Fetch CHANGELOG using the command above
2. Extract the first `## x.x.x` section
3. Categorize changes into:
   - New features (Added)
   - Bug fixes (Fixed)
   - Improvements (Improved/Changed)
   - Deprecations (Deprecated)
4. Present in Japanese with brief explanations

### 3.2. Version Diff

1. Ask user for start and end versions
2. Extract all sections between those versions
3. Summarize cumulative changes
4. Highlight breaking changes and deprecations

### 3.3. Breaking Changes Detection

1. Search for keywords: `Deprecated`, `Removed`, `Breaking`, `Changed`
2. List affected settings and migration paths
3. Check user's config for affected settings

## 4. Specification Reference

For detailed questions about Claude Code specifications, features, and usage:

- YOU MUST: Use the `claude-code-guide` subagent via Task tool
- Example queries: hooks, MCP servers, settings, IDE integrations

```text
Task tool with subagent_type: claude-code-guide
```

## 5. Settings Categories

| Category | Examples                            |
| -------- | ----------------------------------- |
| Display  | `showTurnDuration`, `language`      |
| Behavior | `respectGitignore`, `autoUpdate`    |
| Tools    | `disallowedTools`, `allowedTools`   |
| MCP      | MCP server configurations           |
| Hooks    | PreToolUse, PostToolUse, Stop hooks |
| Plans    | `plansDirectory`                    |

## 6. CLAUDE.md Design Guidelines

- YOU MUST: Focus only on persona and core guidelines
- YOU MUST: Split detailed rules into `rules/`
- NEVER: Include unnecessary information at startup
  (reference links, usage details)

### 6.1. Include vs Exclude

| Include                                              | Exclude                                            |
| ---------------------------------------------------- | -------------------------------------------------- |
| Bash commands Claude can't guess                     | Anything Claude can figure out by reading code     |
| Code style rules that differ from defaults           | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners      | Detailed API documentation (link to docs instead)  |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently                |
| Architectural decisions specific to your project     | Long explanations or tutorials                     |
| Developer environment quirks (required env vars)     | File-by-file descriptions of the codebase          |
| Common gotchas or non-obvious behaviors              | Self-evident practices like "write clean code"     |

Test each line: "Would removing this cause Claude to make mistakes?" If not, cut it.

### 6.2. @import Syntax

CLAUDE.md can import additional files:

```markdown
See @README.md for project overview and @package.json for available npm commands.

# Additional Instructions

- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

### 6.3. CLAUDE.md Locations

| Location              | Scope                                                    |
| --------------------- | -------------------------------------------------------  |
| `~/.claude/CLAUDE.md` | All Claude sessions (global)                             |
| `./CLAUDE.md`         | Project root — check into git to share with team        |
| `./CLAUDE.local.md`   | Project root — add to .gitignore for personal overrides |
| Parent directories    | Useful for monorepos (auto-loaded)                       |
| Child directories     | Loaded on demand when working with files there           |

## 7. Configuration Usage

| Type               | Load Timing                    | Purpose                       |
| ------------------ | ------------------------------ | ----------------------------- |
| CLAUDE.md / rules/ | Full load at startup           | Global rules always applied   |
| commands/          | Explicit user invocation       | Predefined prompts, workflows |
| skills/            | Auto-triggered by conversation | Specialized knowledge         |
| agents/            | Delegated via Task tool        | Independent context           |

## 8. Optimization Checklist

### 8.1. CLAUDE.md Review

Check the following when editing CLAUDE.md:

- [ ] Is the persona definition concise?
- [ ] Are basic rules truly needed at all times?
- [ ] Can detailed explanations be moved to rules/ or skills/?
- [ ] Have reference links been moved to skills?
- [ ] Does each line pass the "remove this → Claude makes mistakes?" test?
- [ ] Are @imports used for large doc sections instead of inline content?
- [ ] Is the file short enough that Claude won't ignore rules buried in the middle?

### 8.2. Permission System Review

Check settings.json permissions block:

- [ ] Are deny rules using modern syntax `Bash(cmd *)` not deprecated `:*`?
- [ ] Are critical commands blocked (git push, git rebase, git reset, rm, sudo)?
- [ ] Is `git -C *` blocked to prevent cross-repo operations?
- [ ] Is defaultMode appropriate ("plan" or "dontAsk")?
- [ ] Are sensitive paths blocked (secrets, .env, .ssh, keys, tokens)?
- [ ] Are allow rules necessary or can defaultMode handle it?

## 9. Skill and Agent Frontmatter Reference

### 9.1. Skill Frontmatter (SKILL.md)

```yaml
---
name: skill-name
description: |
  When to trigger this skill.
  Use when:
  - condition 1
  - condition 2
disable-model-invocation: true # For workflows with side effects (manual invoke only)
---
```

- `disable-model-invocation: true` — Prevents auto-triggering; user must invoke
  explicitly with `/skill-name`. Use for workflows that have side effects.
- Invoke with `$ARGUMENTS` for parameterized workflows: `/fix-issue 1234`

### 9.2. Agent Frontmatter (.claude/agents/\*.md)

```yaml
---
name: agent-name
description: What this agent does and when to use it
tools: Read, Grep, Glob, Bash # Restrict available tools
model: opus # Optional: specify model
isolation: worktree # Run in isolated git worktree (v2.1.49+)
background: true # Always run as background task (v2.1.49+)
---
```

## 10. File Structure Maintenance

When adding/removing files in rules/, skills/, agents/, or commands/:

- YOU MUST: Update corresponding table in CLAUDE.md section 4
- YOU MUST: Keep tables alphabetically sorted or logically grouped
- IMPORTANT: Verify actual files match documentation after changes

## 11. Optimization Tracking

Last reviewed Claude Code version: v2.1.59 (2026-02-27)

### 11.1. Applied Optimizations

- [x] Persona definition minimized
- [x] Rules split into rules/ directory
- [x] Skills split into skills/ directory
- [x] Agents split into agents/ directory
- [x] Commands split into commands/ directory
- [x] Reference links moved to skills
- [x] `language` setting - set to "follow CLAUDE.md's instructions"
- [x] `mcpToolSearch` setting - set to "auto:1"
- [x] `ENABLE_TOOL_SEARCH` env - set to "true" (force enable)
- [x] `plansDirectory` setting - set to use mkoutput
- [x] Permission system reviewed - sandbox bypass fix confirmed (v2.1.34)
- [x] Permission deny rules migrated - deprecated `:*` to modern `*` syntax
- [x] Fast mode - available for Opus 4.6 (v2.1.36)
- [x] Agent teams - enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- [x] Automatic memory - enabled by default (v2.1.32)

### 11.2. Pending Considerations

- [x] SQL schema validation - moved to databricks skill (Section 8)
- [ ] TeammateIdle/TaskCompleted hooks - for future agent workflow automation
- [ ] Agent memory frontmatter - `memory: user|project|local` for stateful
      agents
- [ ] Task(agent_type) restrictions - enhanced security for subagent spawning
- [ ] WorktreeCreate/WorktreeRemove hooks - custom VCS setup/teardown for
      worktree isolation (v2.1.50)
- [ ] ConfigChange hook - security auditing of settings changes (v2.1.49)
- [ ] `isolation: worktree` in agent defs - isolated git worktree per agent
      (v2.1.49, v2.1.50)
- [ ] `background: true` in agent defs - agents always run as background tasks
      (v2.1.49)
- [ ] `claude remote-control` subcommand - external builds / local env serving
      (v2.1.51)
- [ ] Managed settings via macOS plist or Windows Registry (v2.1.51)

### 11.3. Not Adopting

- `showTurnDuration` - keep default (show duration)
- `reducedMotionMode` - keep default (animations enabled)
- Keybindings customization - use defaults
- Completion status reporting - no consumer for this output
- `CLAUDE_BASH_NO_LOGIN` - obsolete since v2.1.51 (auto-skip when snapshot
  available)

### 11.4. Version Notes

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
  **plan mode lost after compaction fix**, bash permission classifier hallucination
  fix, VS Code plan preview auto-update
- v2.1.46: claude.ai MCP connectors support
- v2.1.45: **Claude Sonnet 4.6**, `spinnerTipsOverride` setting,
  Agent Teams Bedrock/Vertex fix, macOS sandbox temp file fix
- v2.1.44: Auth refresh error fix
- v2.1.43: **Fixed AWS auth refresh hanging indefinitely** (3-min timeout), Vertex/Bedrock fixes
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

## 12. Response Format (CHANGELOG)

```text
# Claude Code vX.X.X

## New Features
- [Feature]: [Description]

## Bug Fixes
- [Fix description]

## Improvements
- [Improvement description]

## Deprecated/Removed
- [Affected settings and migration path]

---
Source: https://github.com/anthropics/claude-code
```

## 13. site2skill Usage

Convert documentation websites into Claude Agent Skills.

Requirements: Python 3.10+, wget (`brew install wget`)

```sh
uvx --from git+https://github.com/laiso/site2skill site2skill <URL> <SKILL_NAME>

# Example
uvx --from git+https://github.com/laiso/site2skill site2skill https://docs.pay.jp/v1/ payjp
```

Options:

- `--output, -o` - Output directory (default: `.claude/skills`)
- `--skill-output` - Where to save .skill file (default: current directory)
- `--skip-fetch` - Skip download (reuse existing files)
- `--clean` - Remove temporary files after completion

To update existing skill docs, re-run without `--skip-fetch`.

## 14. Reference Links

Official Documentation:

- Best Practices: <https://code.claude.com/docs/en/best-practices.md>
- Docs Map: <https://code.claude.com/docs/en/claude_code_docs_map.md>

Community Resources:

- Claude Code config: <https://blog.atusy.net/2025/12/15/claude-code-user-config/>
- CLAUDE.md minimization: <https://blog.atusy.net/2025/12/17/minimizing-claude-md/>
- site2skill: <https://github.com/laiso/site2skill>

## 15. Permission System Reference

### 15.1. Permission Modes

| Mode                | Description                                           |
| ------------------- | ----------------------------------------------------- |
| `default`           | Prompts for permission on first use of each tool      |
| `acceptEdits`       | Auto-accepts file edit permissions for the session    |
| `plan`              | Plan Mode: analyze only, no modifications             |
| `dontAsk`           | Auto-denies unless pre-approved via allow rules       |
| `bypassPermissions` | Skips all prompts (use only in isolated environments) |

### 15.2. Rule Evaluation Order

Rules are evaluated: **deny -> ask -> allow**. First matching rule wins.

### 15.3. Bash Wildcard Patterns

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Bash(* --version)",
      "Bash(* --help *)"
    ],
    "deny": ["Bash(git push *)"]
  }
}
```

NOTE: Space before `*` matters: `Bash(ls *)` matches `ls -la` but not `lsof`.

### 15.4. Read/Edit Path Patterns

| Pattern  | Meaning                       | Example                  |
| -------- | ----------------------------- | ------------------------ |
| `//path` | Absolute path from root       | `Read(//Users/alice/**)` |
| `~/path` | Path from home directory      | `Read(~/.zshrc)`         |
| `/path`  | Relative to settings file     | `Edit(/src/**/*.ts)`     |
| `path`   | Relative to current directory | `Read(*.env)`            |

NOTE: `*` matches single directory, `**` matches recursively.

### 15.5. MCP and Task Permissions

```json
{
  "permissions": {
    "allow": ["mcp__puppeteer__*"],
    "deny": ["Task(Explore)"]
  }
}
```

### 15.6. Managed Settings Locations

| Platform  | Path                                                            |
| --------- | --------------------------------------------------------------- |
| macOS     | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json`                        |
| Windows   | `C:\Program Files\ClaudeCode\managed-settings.json`             |

### 15.7. Managed-Only Settings

| Setting                           | Description                             |
| --------------------------------- | --------------------------------------- |
| `disableBypassPermissionsMode`    | Set to "disable" to prevent bypass mode |
| `allowManagedPermissionRulesOnly` | Only managed rules apply                |
| `allowManagedHooksOnly`           | Only managed/SDK hooks allowed          |

## 16. Insights-Based Recommendations

Based on usage analysis (55K messages, 4.7K sessions):

### 16.1. Applied

- Schema validation for DB operations: See databricks skill Section 8

### 16.2. Not Applied

- Completion status reporting: No consumer for this output
- PreToolUse hook for SQL: Handled by skill guidance instead

## 17. References

- Hooks Reference: `https://code.claude.com/docs/en/hooks`
- Permissions Reference: `https://code.claude.com/docs/en/permissions`
- Skills Dynamic Context: `https://code.claude.com/docs/en/skills#inject-dynamic-context`
- Vercel AGENTS.md Guide: `https://vercel.com/blog/agents-md`
