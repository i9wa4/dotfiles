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

User's Claude Code config is stored at:
@~/ghq/github.com/i9wa4/dotfiles/config/agents/
@~/ghq/github.com/i9wa4/dotfiles/config/claude/

Key files:

- `settings.json` - Main settings
- `CLAUDE.md` - Persona and core rules
- `rules/` - Detailed rules (auto-loaded at startup)
- `skills/` - Specialized knowledge (loaded on demand)
- `agents/` - Custom agents
- `commands/` - Slash commands

## 2. Fetch CHANGELOG

Use `gh` command to fetch the latest CHANGELOG:

```sh
gh api repos/anthropics/claude-code/contents/CHANGELOG.md \
  --jq '.content' | base64 -d > .i9wa4/tmp/claude-code-changelog.md
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

### 8.2. Permission System Review

Check settings.json permissions block:

- [ ] Are deny rules using modern syntax `Bash(cmd *)` not deprecated `:*`?
- [ ] Are critical commands blocked (git push, git rebase, git reset, rm, sudo)?
- [ ] Is `git -C *` blocked to prevent cross-repo operations?
- [ ] Is defaultMode appropriate ("plan" or "dontAsk")?
- [ ] Are sensitive paths blocked (secrets, .env, .ssh, keys, tokens)?
- [ ] Are allow rules necessary or can defaultMode handle it?

## 9. File Structure Maintenance

When adding/removing files in rules/, skills/, agents/, or commands/:

- YOU MUST: Update corresponding table in CLAUDE.md section 4
- YOU MUST: Keep tables alphabetically sorted or logically grouped
- IMPORTANT: Verify actual files match documentation after changes

## 10. Optimization Tracking

Last reviewed Claude Code version: v2.1.37 (2026-02-09)

### 10.1. Applied Optimizations

- [x] Persona definition minimized
- [x] Rules split into rules/ directory
- [x] Skills split into skills/ directory
- [x] Agents split into agents/ directory
- [x] Commands split into commands/ directory
- [x] Reference links moved to skills
- [x] `language` setting - set to "follow CLAUDE.md's instructions"
- [x] `mcpToolSearch` setting - set to "auto:1"
- [x] `ENABLE_TOOL_SEARCH` env - set to "true" (force enable)
- [x] `plansDirectory` setting - set to ".i9wa4/plans"
- [x] Permission system reviewed - sandbox bypass fix confirmed (v2.1.34)
- [x] Permission deny rules migrated - deprecated `:*` to modern `*` syntax
- [x] Fast mode - available for Opus 4.6 (v2.1.36)
- [x] Agent teams - enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- [x] Automatic memory - enabled by default (v2.1.32)

### 10.2. Pending Considerations

- [x] SQL schema validation - moved to databricks skill (Section 8)
- [ ] TeammateIdle/TaskCompleted hooks - for future agent workflow automation
- [ ] Agent memory frontmatter - `memory: user|project|local` for stateful
      agents
- [ ] Task(agent_type) restrictions - enhanced security for subagent spawning

### 10.3. Not Adopting

- `showTurnDuration` - keep default (show duration)
- `reducedMotionMode` - keep default (animations enabled)
- Keybindings customization - use defaults
- Completion status reporting - no consumer for this output

### 10.4. Version Notes

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

## 11. Response Format (CHANGELOG)

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

## 12. site2skill Usage

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

## 13. Reference Links

Official Documentation:

- Best Practices: <https://code.claude.com/docs/en/best-practices.md>
- Docs Map: <https://code.claude.com/docs/en/claude_code_docs_map.md>

Community Resources:

- Claude Code config: <https://blog.atusy.net/2025/12/15/claude-code-user-config/>
- CLAUDE.md minimization: <https://blog.atusy.net/2025/12/17/minimizing-claude-md/>
- site2skill: <https://github.com/laiso/site2skill>

## 14. Permission System Reference

### 14.1. Permission Modes

| Mode                | Description                                           |
| ------------------- | ----------------------------------------------------- |
| `default`           | Prompts for permission on first use of each tool      |
| `acceptEdits`       | Auto-accepts file edit permissions for the session    |
| `plan`              | Plan Mode: analyze only, no modifications             |
| `dontAsk`           | Auto-denies unless pre-approved via allow rules       |
| `bypassPermissions` | Skips all prompts (use only in isolated environments) |

### 14.2. Rule Evaluation Order

Rules are evaluated: **deny -> ask -> allow**. First matching rule wins.

### 14.3. Bash Wildcard Patterns

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

### 14.4. Read/Edit Path Patterns

| Pattern  | Meaning                       | Example                  |
| -------- | ----------------------------- | ------------------------ |
| `//path` | Absolute path from root       | `Read(//Users/alice/**)` |
| `~/path` | Path from home directory      | `Read(~/.zshrc)`         |
| `/path`  | Relative to settings file     | `Edit(/src/**/*.ts)`     |
| `path`   | Relative to current directory | `Read(*.env)`            |

NOTE: `*` matches single directory, `**` matches recursively.

### 14.5. MCP and Task Permissions

```json
{
  "permissions": {
    "allow": ["mcp__puppeteer__*"],
    "deny": ["Task(Explore)"]
  }
}
```

### 14.6. Managed Settings Locations

| Platform  | Path                                                            |
| --------- | --------------------------------------------------------------- |
| macOS     | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json`                        |
| Windows   | `C:\Program Files\ClaudeCode\managed-settings.json`             |

### 14.7. Managed-Only Settings

| Setting                           | Description                             |
| --------------------------------- | --------------------------------------- |
| `disableBypassPermissionsMode`    | Set to "disable" to prevent bypass mode |
| `allowManagedPermissionRulesOnly` | Only managed rules apply                |
| `allowManagedHooksOnly`           | Only managed/SDK hooks allowed          |

## 15. Insights-Based Recommendations

Based on usage analysis (55K messages, 4.7K sessions):

### 15.1. Applied

- Schema validation for DB operations: See databricks skill Section 8

### 15.2. Not Applied

- Completion status reporting: No consumer for this output
- PreToolUse hook for SQL: Handled by skill guidance instead

## 16. References

- Hooks Reference: `https://code.claude.com/docs/en/hooks`
- Permissions Reference: `https://code.claude.com/docs/en/permissions`
- Skills Dynamic Context: `https://code.claude.com/docs/en/skills#inject-dynamic-context`
- Vercel AGENTS.md Guide: `https://vercel.com/blog/agents-md`
