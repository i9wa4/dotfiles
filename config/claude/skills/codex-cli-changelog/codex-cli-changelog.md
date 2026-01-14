# Codex CLI CHANGELOG Skill

Track Codex CLI updates and summarize release notes.

## 1. Fetch Releases

Use `gh` command to fetch the latest releases:

```sh
gh api repos/openai/codex/releases --jq '.[0:5]' > /tmp/codex-cli-releases.json
```

Then read the file to analyze.

## 2. Operations

### 2.1. Latest Release Summary

Summarize the latest version's changes in Japanese:

1. Fetch releases using the command above
2. Extract the first release entry
3. Categorize changes into:
   - New features (Added)
   - Bug fixes (Fixed)
   - Improvements (Improved/Changed)
   - Breaking changes
4. Present in Japanese with brief explanations

### 2.2. Version Diff

Compare changes between two versions:

1. Ask user for start and end versions
2. Extract all releases between those versions
3. Summarize cumulative changes
4. Highlight breaking changes and deprecations

### 2.3. Breaking Changes Detection

Extract breaking changes:

1. Search for keywords: `breaking`, `removed`, `deprecated`,
   `changed` (behavior changes)
2. List affected commands and options
3. Provide migration guidance

## 3. Response Format

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

## 4. Important Notes

- Codex CLI changelog is on the releases page, not CHANGELOG.md
- Use GitHub releases API to fetch release notes
- Always specify the version being referenced
- Link to official release page when available
