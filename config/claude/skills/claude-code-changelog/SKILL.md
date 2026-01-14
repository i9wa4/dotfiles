---
name: claude-code-changelog
description: |
  Claude Code CHANGELOG catchup skill.
  Use when:
  - User says "claude code changelog" or "claude code updates"
  - User says "claude codeの更新" or "claude codeの変更点"
  - User asks about new features or breaking changes in Claude Code
  - Need to check if current config uses deprecated settings
---

# Claude Code CHANGELOG Skill

Track Claude Code updates and get improvement suggestions
for your configuration.

## 1. Fetch CHANGELOG

Use `gh` command to fetch the latest CHANGELOG:

```sh
gh api repos/anthropics/claude-code/contents/CHANGELOG.md --jq '.content' | base64 -d > /tmp/claude-code-changelog.md
```

Then read the file to analyze.

## 2. Operations

### 2.1. Latest Release Summary

Summarize the latest version's changes in Japanese:

1. Fetch CHANGELOG using the command above
2. Extract the first `## x.x.x` section
3. Categorize changes into:
   - New features (Added)
   - Bug fixes (Fixed)
   - Improvements (Improved/Changed)
   - Deprecations (Deprecated)
4. Present in Japanese with brief explanations

### 2.2. Version Diff

Compare changes between two versions:

1. Ask user for start and end versions
2. Extract all sections between those versions
3. Summarize cumulative changes
4. Highlight breaking changes and deprecations

### 2.3. Breaking Changes Detection

Extract breaking changes and deprecations:

1. Search for keywords: `Deprecated`, `Removed`, `Breaking`,
   `Changed` (behavior changes)
2. List affected settings and migration paths
3. Check user's config for affected settings

### 2.4. Config Improvement Suggestions

Analyze user's Claude Code config and suggest improvements:

1. Read user's settings from:
   - `~/.claude/settings.json`
   - `~/.claude.json`
   - `.claude/settings.json` (project-level)
2. Compare against new features in CHANGELOG
3. Suggest:
   - New settings that might be useful
   - Deprecated settings to remove
   - Performance optimizations
   - Security improvements

## 3. Settings to Watch

Common settings categories in Claude Code:

| Category | Examples |
| -------- | -------- |
| Display | `showTurnDuration`, `language` |
| Behavior | `respectGitignore`, `autoUpdate` |
| Tools | `disallowedTools`, `allowedTools` |
| MCP | MCP server configurations |
| Hooks | PreToolUse, PostToolUse, Stop hooks |

## 4. Response Format

```text
# Claude Code vX.X.X 更新内容

## 新機能
- [機能名]: [説明]

## バグ修正
- [修正内容]

## 改善
- [改善内容]

## 非推奨/削除
- [影響を受ける設定と移行方法]

---
Source: https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md
```

## 5. Config Check Workflow

When user asks for config improvement suggestions:

1. Fetch latest CHANGELOG
2. Read user's settings files
3. Cross-reference new settings against user's config
4. Generate improvement suggestions with:
   - Setting name
   - Description
   - Recommended value
   - Reason for recommendation

## 6. Important Notes

- Always specify the CHANGELOG version being referenced
- Provide migration guidance for deprecated settings
- Consider user's environment (VSCode, terminal, OS) when suggesting
- Link to official documentation when available
