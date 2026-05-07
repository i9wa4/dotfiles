# vde-layout Internals

Short reference for vde-layout config resolution and preset structure.

## Config Resolution

- Binary:
  `/home/daiki.mawatari/.local/lib/node_modules/vde-layout/dist/index.mjs`
- Config loaded from `$VDE_CONFIG_PATH` env var, or default XDG path:
  `$XDG_CONFIG_HOME/vde/layout.yml` → `~/.config/vde/layout.yml`
- `~/.config/vde` is Home Manager-managed; the layout file resolves to
  `dotfiles/config/vde/layout.yml`

## Preset Definitions (layout.yml)

| Preset           | Lines    | windowMode      | Panes |
| ---------------- | -------- | --------------- | ----- |
| messenger-claude | 40-54    | current-window  | editor + messenger (claude sonnet medium) |
| messenger-codex  | 56-70    | current-window  | editor + messenger (codex gpt-5.5 medium) |
| preset-a         | 72-109   | new-window      | 3x2 grid: see SKILL.md Section 2 |
| preset-b         | 111-148  | new-window      | 3x2 grid: all codex gpt-5.5 xhigh |

## Key Behavioral Notes

- `${SUBDIR}` in command strings is NOT interpolated by vde-layout — it is
  passed as-is to `tmux send-keys` and expanded by the destination pane's shell
- `delay` field (ms) is honored before sending agent command per pane
- Pane title set via `tmux select-pane -T <title>` after split-window
- No `env:` keys are used in the current layout.yml — `$SUBDIR` expansion relies
  on shell environment
