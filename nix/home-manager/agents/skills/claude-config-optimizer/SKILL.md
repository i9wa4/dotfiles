---
name: claude-config-optimizer
description: |
  Claude Code config optimization skill.
  Use when:
  - Editing CLAUDE.md, skills/, agents/, commands/
  - User asks about config best practices
  - Checking optimization status
  - User says "claude code changelog" or "claude code updates"
  - User asks about new features or breaking changes in Claude Code
---

# Claude Config Optimizer Skill

Rules and tracking for Claude Code configuration optimization.

## 1. Config File Location

Config is managed declaratively via Nix (`programs.claude-code` home-manager
module).

Source of truth:

- @~/ghq/github.com/i9wa4/dotfiles/nix/home-manager/agents/claude-code.nix
- @~/ghq/github.com/i9wa4/dotfiles/nix/home-manager/agents/

| Destination               | Source                                                       | Managed by                 |
| ------------------------- | ------------------------------------------------------------ | -------------------------- |
| `~/.claude/settings.json` | Generated from Nix attributes                                | `claude-code.nix`          |
| `~/.claude/CLAUDE.md`     | Generated from `AGENTS.md` + `CLAUDE.md` fragment            | `instruction-artifacts.nix` |
| `~/.claude/rules/`        | `nix/home-manager/agents/skills/<name>/SKILL.md`            | `claude-code.nix`          |
| `~/.claude/agents/`       | `nix/home-manager/agents/subagents/`                         | `claude-code.nix`          |
| `~/.claude/scripts/`      | `nix/home-manager/agents/scripts/`                           | `claude-code.nix`          |
| `~/.claude/skills/`       | Multiple flake inputs + local                                | `agent-skills.nix`         |
| MCP servers               | `nix/home-manager/agents/mcp-servers.nix`                    | `claude-code.nix`          |

## 2. Fetch CHANGELOG

### 2.1. Detect Local Version

Always detect the installed version first:

```sh
claude --version
```

This returns the locally installed version (e.g. `2.1.72 (Claude Code)`).
All CHANGELOG analysis MUST be scoped to this version and below.
Do NOT report features or changes from versions newer than the local install.

### 2.2. Fetch from GitHub

```sh
FILE=$(mkmd --dir tmp --label claude-code-changelog)
gh api repos/anthropics/claude-code/contents/CHANGELOG.md \
  --jq '.content' | base64 -d > "$FILE"
```

Then read the file, but only analyze sections up to and including the local
version.

## 3. CHANGELOG Operations

IMPORTANT: All operations below are scoped to the locally installed version.
Ignore any CHANGELOG sections for versions newer than `claude --version`.

### 3.1. Latest Release Summary

1. Detect local version with `claude --version`
2. Fetch CHANGELOG using the command above
3. Extract the `## <local-version>` section (not the first section)
4. Categorize changes into:
   - New features (Added)
   - Bug fixes (Fixed)
   - Improvements (Improved/Changed)
   - Deprecations (Deprecated)
5. Present in Japanese with brief explanations

### 3.2. Version Diff

1. Detect local version with `claude --version`
2. Ask user for start version (end version defaults to local version)
3. Extract all sections between start and local version (inclusive)
4. Summarize cumulative changes
5. Highlight breaking changes and deprecations

### 3.3. Breaking Changes Detection

1. Detect local version with `claude --version`
2. Search sections up to local version for: `Deprecated`, `Removed`,
   `Breaking`, `Changed`
3. List affected settings and migration paths
4. Check user's config for affected settings

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
- YOU MUST: Split detailed rules into `skills/<name>/SKILL.md`
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

Test each line: "Would removing this cause Claude to make mistakes?" If not, cut
it.

### 6.2. @import Syntax

CLAUDE.md can import additional files:

```markdown
See @README.md for project overview and @package.json for available npm
commands.

# Additional Instructions

- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

### 6.3. CLAUDE.md Locations

| Location              | Scope                                                   |
| --------------------- | ------------------------------------------------------- |
| `~/.claude/CLAUDE.md` | All Claude sessions (global)                            |
| `./CLAUDE.md`         | Project root — check into git to share with team        |
| `./CLAUDE.local.md`   | Project root — add to .gitignore for personal overrides |
| Parent directories    | Useful for monorepos (auto-loaded)                      |
| Child directories     | Loaded on demand when working with files there          |

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
- [ ] Can detailed explanations be moved to `skills/<name>/SKILL.md`?
- [ ] Have reference links been moved to skills?
- [ ] Does each line pass the "remove this → Claude makes mistakes?" test?
- [ ] Are @imports used for large doc sections instead of inline content?
- [ ] Is the file short enough that Claude won't ignore rules buried in the
  middle?

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

When adding/removing files in skills/, agents/, or commands/:

- YOU MUST: Update corresponding table in CLAUDE.md section 4
- YOU MUST: Keep tables alphabetically sorted or logically grouped
- IMPORTANT: Verify actual files match documentation after changes

## 11. Optimization Tracking

Last reviewed Claude Code version: v2.1.94 (2026-04-09)

### 11.1. Applied Optimizations

- [x] Persona definition minimized
- [x] Rules split into rules/ directory
- [x] Skills split into skills/ directory
- [x] Agents split into agents/ directory
- [x] Commands split into commands/ directory
- [x] Reference links moved to skills
- [x] `language` setting - set to "English"
- [x] `ENABLE_TOOL_SEARCH` env - set to "auto:3"
- [x] Permission system reviewed - sandbox bypass fix confirmed (v2.1.34)
- [x] Permission deny rules migrated - deprecated `:*` to modern `*` syntax
- [x] Fast mode - available for Opus 4.6 (v2.1.36)
- [x] Agent teams - enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
- [x] Automatic memory - enabled by default (v2.1.32)
- [x] `CLAUDE_CODE_ENABLE_TASKS` env - removed (tasks enabled by default)
- [x] `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` removed - enables Remote
  Control and feature flag refresh (v2.1.51+)
- [x] `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "70"` - autocompact at 70% context
  usage
- [x] `includeGitInstructions = false` - disables built-in git instructions;
  custom `skills/github/SKILL.md` is sole authority (v2.1.69)
- [x] `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "1"` - strips credentials from
  subprocesses (v2.1.83)
- [x] `showThinkingSummaries = true` - explicit opt-in required after v2.1.89
  default change (thinking summaries no longer generated by default in
  interactive sessions)
- [x] `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` - intentionally left unset
  (adaptive thinking stays ON). Combined with startup `/effort high`, mirrors
  the Team/Enterprise default formalized in v2.1.94. See decision log in
  references/changelog-tracking.md for full rationale and HN discussion link.

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
- [ ] PostCompact hook - archive/analyze compaction summaries; has
  `compact_summary` field (v2.1.76)
- [ ] Elicitation/ElicitationResult hooks - intercept MCP server structured
  input requests (v2.1.76)
- [ ] Conditional `if` field for hooks - reduce process spawning overhead
  with permission rule syntax filtering (v2.1.85)
- [ ] StopFailure hook - log API errors (rate limit, auth failure) (v2.1.78)
- [ ] `hookSpecificOutput.sessionTitle` in UserPromptSubmit hooks (v2.1.94) -
  dynamic session/tmux pane title per prompt
- [ ] `CLAUDE_CODE_NO_FLICKER=1` env (v2.1.89) - flicker-free alt-screen
  rendering; revisit if rendering glitches observed

For decision log ("Not Adopting") and per-version changelog,
see [Changelog Tracking](references/changelog-tracking.md).

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

- Claude Code config:
  <https://blog.atusy.net/2025/12/15/claude-code-user-config/>
- CLAUDE.md minimization:
  <https://blog.atusy.net/2025/12/17/minimizing-claude-md/>
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
- Skills Dynamic Context:
  `https://code.claude.com/docs/en/skills#inject-dynamic-context`
- Vercel AGENTS.md Guide: `https://vercel.com/blog/agents-md`
