---
name: codex-config-optimizer
description: |
  Codex CLI config optimization skill.
  Use when:
  - Editing agents.md or agents/
  - User asks about Codex CLI config best practices
  - User says "codex cli changelog" or "codex cli updates"
  - User asks about new features or changes in Codex CLI
---

# Codex CLI Optimizer Skill

Rules and tracking for Codex CLI configuration optimization.

See frontmatter schema: ~/ghq/github.com/i9wa4/internal/docs/schema/frontmatter-schema.md

## 1. Config File Location

User's Codex CLI config is stored at:
@~/ghq/github.com/i9wa4/dotfiles/config/agents/
@~/ghq/github.com/i9wa4/dotfiles/config/codex/

Key files:

| File                 | Git | Description                               |
| -------------------- | --- | ----------------------------------------- |
| `config.common.toml` | Yes | Common settings (model, MCP, etc.)        |
| `AGENTS.md`          | No  | Symlink to `../claude/CLAUDE.md`          |
| `skills/`            | No  | Symlink to `../claude/skills/`            |
| `config.toml`        | No  | Manually managed (common + trusted repos) |

## 2. Config Management

### 2.1. Why separate common and full config?

`config.toml` contains full paths for trusted projects:

```toml
[projects."/Users/uma/ghq/github.com/foo/bar"]
trust_level = "trusted"
```

This path includes username, so `config.toml` cannot be shared across
machines with different usernames. Solution:

- `config.common.toml` - Shared settings (Git-managed)
- `config.toml` - Manually managed, machine-specific (Git-ignored)

### 2.2. How to update

1. Edit `config.common.toml` for shared settings
2. Copy shared settings to `config.toml` manually
3. Add project-specific `[projects."..."]` entries as needed

## 3. Fetch Releases

Use `gh` command to fetch the latest releases:

```sh
FILE=$(mkoutput --dir tmp --label output)
gh api repos/openai/codex/releases --jq '.[0:5]' > "$FILE"
cat "$FILE"
```

## 4. CHANGELOG Operations

### 4.1. Latest Release Summary

1. Fetch releases using the command above
2. Extract the first release entry
3. Categorize changes into:
   - New features (Added)
   - Bug fixes (Fixed)
   - Improvements (Improved/Changed)
   - Breaking changes
4. Present in Japanese with brief explanations

### 4.2. Version Diff

1. Ask user for start and end versions
2. Extract all releases between those versions
3. Summarize cumulative changes
4. Highlight breaking changes and deprecations

### 4.3. Breaking Changes Detection

1. Search for keywords: `breaking`, `removed`, `deprecated`,
   `changed` (behavior changes)
2. List affected commands and options
3. Provide migration guidance

## 5. Settings Categories

| Category  | Examples                                             |
| --------- | ---------------------------------------------------- |
| Model     | `model`, `model_reasoning`, `model_reasoning_effort` |
| Behavior  | `approval_mode`, `sandbox`, `network_access`         |
| Display   | `notify`, `tui.notifications_method`                 |
| Shell     | `shell_environment_commands`                         |
| History   | `history`, `project_doc_max_bytes`                   |
| Features  | `features.skills`, `features.web_search_request`     |
| Disable   | `disable_response_storage`, `hide_agent_*`           |
| Analytics | `analytics.enabled`, `feedback.enabled`              |

## 6. AGENTS.md Design Guidelines

- YOU MUST: Focus only on persona and core guidelines
- YOU MUST: Keep instructions compatible with both Claude Code and Codex CLI
- NEVER: Include tool-specific syntax (e.g., Claude Code's TodoWrite)

## 7. Optimization Checklist

Check the following when editing AGENTS.md or config.toml:

- [ ] Is the persona definition concise?
- [ ] Are basic rules truly needed at all times?
- [ ] Can detailed explanations be moved to skills/?
- [ ] Is config.toml using appropriate approval_mode?

## 8. Optimization Tracking

Last reviewed Codex CLI version: v0.104.0 (2026-02-23)

### 8.1. Applied Optimizations

- [x] AGENTS.md symlinked to CLAUDE.md (shared persona)
- [x] skills/ symlinked to Claude Code skills
- [x] config.common.toml for shared settings

### 8.2. Pending Considerations

- [ ] Create prompts/ symlink to `../claude/commands/` if needed
- [ ] Create generate-config.sh for automated config.toml generation
- [ ] Evaluate MCP server integration (AWS docs MCP etc.)
- [ ] Review `tui.notifications_method` config option (added in v0.93.0)
- [x] Plan mode (`/plan`) - now stable and enabled by default (v0.94.0)
- [ ] Review smart approvals default behavior (enabled in v0.93.0)
- [ ] `personality` setting - now stable (default: "friendly"); consider
      setting explicitly or using `personality = "pragmatic"` (v0.94.0)
- [ ] `AfterToolUse` hook - new hook event for post-tool automation (v0.99.0)
- [x] `command_attribution = "disable"` - co-author attribution disabled
      (v0.103.0)
- [ ] `approval_policy: on-failure` - deprecated; review if used (v0.102.0)
- [ ] `log_dir` config - redirect logs to custom directory (v0.97.0)

### 8.3. Version Notes

- v0.104.0: `WS_PROXY`/`WSS_PROXY` env for websocket proxying,
  `ConfigChange` hook from app-server, command approval ID plumbing
- v0.103.0: Commit co-author attribution via `command_attribution` config,
  richer app details in listings
- v0.102.0: Unified permissions flow with TUI history, slash command to grant
  sandbox read access, customizable multi-agent roles, `model/rerouted`
  notification, `approval_policy: on-failure` deprecated
- v0.101.0: Bug fixes for memory and model resolution
- v0.100.0: Experimental JS REPL runtime, memory slash commands
  (`/m_update`, `/m_drop`), `ReadOnlyAccess` sandbox policy,
  `AfterToolUse` hook
- v0.99.0: `/statusline` command for TUI footer config, shell commands no
  longer interrupt in-flight turns, GIF/WebP image support, `AfterToolUse`
  hook added, security fix (RUSTSEC-2026-0009)
- v0.98.0: **GPT-5.3-Codex** model introduced, steer mode stable by default
  (Enter sends, Tab queues)
- v0.97.0: "Allow and remember" for MCP/App tools, live skill updates,
  `/debug-config` slash command, configurable `log_dir`
- v0.96.0: `unified_exec` enabled on all non-Windows platforms
- v0.95.0: `~/.agents/skills` personal skill loading, `/plan` accepts args
  and images, parallel shell tools, `CODEX_THREAD_ID` env injected
- v0.94.0: **Plan mode enabled by default**, `personality` config stable
  (default: friendly), skills from `.agents/skills`

## 9. Response Format (CHANGELOG)

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

## 10. Important Notes

- Codex CLI changelog is on the releases page, not CHANGELOG.md
- Use GitHub releases API to fetch release notes
- Always specify the version being referenced
- Link to official release page when available

## 11. Reference Links

- Codex CLI: <https://github.com/openai/codex>
