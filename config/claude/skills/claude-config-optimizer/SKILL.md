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

```text
~/ghq/github.com/i9wa4/dotfiles/config/claude/
```

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
  --jq '.content' | base64 -d > /tmp/claude-code-changelog.md
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

## 4. Settings Categories

| Category | Examples                            |
| -------- | --------                            |
| Display  | `showTurnDuration`, `language`      |
| Behavior | `respectGitignore`, `autoUpdate`    |
| Tools    | `disallowedTools`, `allowedTools`   |
| MCP      | MCP server configurations           |
| Hooks    | PreToolUse, PostToolUse, Stop hooks |
| Plans    | `plansDirectory`                    |

## 5. CLAUDE.md Design Guidelines

- YOU MUST: Focus only on persona and core guidelines
- YOU MUST: Split detailed rules into `rules/`
- NEVER: Include unnecessary information at startup
  (reference links, usage details)

## 6. Configuration Usage

| Type               | Load Timing                    | Purpose                       |
| ----               | -----------                    | -------                       |
| CLAUDE.md / rules/ | Full load at startup           | Global rules always applied   |
| commands/          | Explicit user invocation       | Predefined prompts, workflows |
| skills/            | Auto-triggered by conversation | Specialized knowledge         |
| agents/            | Delegated via Task tool        | Independent context           |

## 7. Optimization Checklist

Check the following when editing CLAUDE.md:

- [ ] Is the persona definition concise?
- [ ] Are basic rules truly needed at all times?
- [ ] Can detailed explanations be moved to rules/ or skills/?
- [ ] Have reference links been moved to skills/?

## 8. File Structure Maintenance

When adding/removing files in rules/, skills/, agents/, or commands/:

- YOU MUST: Update corresponding table in CLAUDE.md section 4
- YOU MUST: Keep tables alphabetically sorted or logically grouped
- IMPORTANT: Verify actual files match documentation after changes

## 9. Optimization Tracking

Last reviewed Claude Code version: v2.1.12 (2026-01-20)

### 9.1. Applied Optimizations

- [x] Persona definition minimized
- [x] Rules split into rules/ directory
- [x] Skills split into skills/ directory
- [x] Agents split into agents/ directory
- [x] Commands split into commands/ directory
- [x] Reference links moved to skills
- [x] `language` setting - set to "follow CLAUDE.md's instructions"
- [x] `mcpToolSearch` setting - set to "auto:5"
- [x] `plansDirectory` setting - set to ".i9wa4/plans"

### 9.2. Pending Considerations

- [ ] `showTurnDuration` setting - hide "Cooked for Xm Xs" messages
- [ ] Keybindings customization via `~/.claude/keybindings.json`

### 9.3. Version Notes

- v2.1.10: Setup hook, OAuth URL copy shortcut, heredoc template literal fix
- v2.1.9: plansDirectory, auto:N for MCP, PreToolUse additionalContext
- v2.1.7: keybindings.json, showTurnDuration, MCP tool search auto mode
- v2.1.3: Merged slash commands and skills
- v2.1.0: language setting, skill hot-reload, context: fork

## 10. Response Format (CHANGELOG)

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

## 11. Reference Links

- Claude Code config: <https://blog.atusy.net/2025/12/15/claude-code-user-config/>
- CLAUDE.md minimization: <https://blog.atusy.net/2025/12/17/minimizing-claude-md/>
- site2skill: <https://github.com/laiso/site2skill>
