# Claude Code Harness Reference

Runtime-specific rules and tracking for Claude Code configuration inside the
shared agent harness. Use this as the detailed reference from the
`dotfiles` skill.

## 1. Config File Location

Config is managed declaratively via Nix (`programs.claude-code` home-manager
module).

Source of truth:

- Binary package: `llmAgents.claude-code` in `nix/home-manager/default.nix`
- `nix/home-manager/agents/claude/default.nix`
- `nix/home-manager/agents/shared/`
- `nix/home-manager/agents/`

| Destination              | Source                                                | Managed by                           |
| ------------------------ | ----------------------------------------------------- | ------------------------------------ |
| Claude settings file     | Generated from Nix attributes                         | `claude/default.nix`                 |
| no root instruction file | Persona / language / scope from postman common blocks | `config/tmux-a2a-postman/postman.md` |
| Claude agents directory  | Generated Markdown from `subagents/*.md` + metadata   | `shared/install-manifest.nix`        |
| Claude scripts directory | `nix/home-manager/agents/scripts/`                    | `claude/default.nix`                 |
| Claude skills directory  | Multiple flake inputs + local skills                  | `shared/agent-skills.nix`            |
| MCP servers              | `shared/mcp-servers.nix`                              | `claude/default.nix`                 |

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

For detailed questions about Claude Code specifications, features, and usage,
prefer official Claude Code documentation or a dedicated guide workflow when one
is available in the active runtime. Do not spawn a subagent only because this
reference was loaded; follow the current session's delegation policy.

## 5. Settings Categories

| Category | Examples                            |
| -------- | ----------------------------------- |
| Display  | `showTurnDuration`, `language`      |
| Behavior | `respectGitignore`, `autoUpdate`    |
| Tools    | `disallowedTools`, `allowedTools`   |
| MCP      | MCP server configurations           |
| Hooks    | PreToolUse, PostToolUse, Stop hooks |
| Plans    | `plansDirectory`                    |

## 6. Upstream CLAUDE.md Design Guidelines

This section is general Claude Code guidance. This repo does not install a root
Claude global instruction file; dotfiles-local persona and scope are delivered
through `config/tmux-a2a-postman/postman.md` instead.

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
- Personal overrides: @CLAUDE.local.md
```

### 6.3. CLAUDE.md Locations

| Location            | Scope                                                   |
| ------------------- | ------------------------------------------------------- |
| Global Claude file  | All Claude sessions                                     |
| `./CLAUDE.md`       | Project root — check into git to share with team        |
| `./CLAUDE.local.md` | Project root — add to .gitignore for personal overrides |
| Parent directories  | Useful for monorepos (auto-loaded)                      |
| Child directories   | Loaded on demand when working with files there          |

## 7. Configuration Usage

| Type                     | Load Timing                    | Purpose                       |
| ------------------------ | ------------------------------ | ----------------------------- |
| settings and postman     | Activation and postman pop     | Runtime config and role rules |
| commands/                | Explicit user invocation       | Predefined prompts, workflows |
| skills/                  | Auto-triggered by conversation | Specialized knowledge         |
| agents/                  | Delegated via Task tool        | Independent context           |
| project instruction docs | Startup or directory traversal | Project-local guidance        |

## 8. Optimization Checklist

### 8.1. CLAUDE.md Review

Check the following only when editing a project-specific Claude instruction
file outside this repo-managed root setup:

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
- [ ] Is `git -C *` blocked so agents `cd` into the target worktree and let
  direnv load before running git?
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
# For workflows with side effects (manual invoke only)
disable-model-invocation: true
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

- YOU MUST: Update `nix/home-manager/agents/README.md` or the relevant doc
  table when installed surfaces change
- YOU MUST: Keep tables alphabetically sorted or logically grouped
- IMPORTANT: Verify actual files match documentation after changes

## 11. Optimization Tracking

Current Claude Code optimization decisions and pending considerations live in
[Claude Code Optimization Tracking](claude-optimization-tracking.md).

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
uvx --from git+https://github.com/laiso/site2skill site2skill \
  https://docs.pay.jp/v1/ payjp
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

| Pattern  | Meaning                       | Example              |
| -------- | ----------------------------- | -------------------- |
| `//path` | Absolute path from root       | `Read(//var/log/**)` |
| `~/path` | Path from home directory      | `Read(~/notes.md)`   |
| `/path`  | Relative to settings file     | `Edit(/src/**/*.ts)` |
| `path`   | Relative to current directory | `Read(*.env)`        |

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
