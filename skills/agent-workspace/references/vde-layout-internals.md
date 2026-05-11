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

| Preset          | Lines  | windowMode     | Panes                                      |
| --------------- | ------ | -------------- | ------------------------------------------ |
| main            | 2-29   | current-window | postman, tailscale, agent, vde-monitor     |
| dev             | 31-45  | current-window | pane + agent                               |
| messenger-codex | 47-61  | current-window | pane + messenger (codex gpt-5.5 medium)    |
| preset-a        | 63-100 | new-window     | 3x2 grid: 5 codex panes + critic in claude |

## Key Behavioral Notes

- `${SUBDIR}` in command strings is NOT interpolated by vde-layout — it is
  passed as-is to `tmux send-keys` and expanded by the destination pane's shell
- `delay` field (ms) is honored before sending agent command per pane
- Pane title set via `tmux select-pane -T <title>` after split-window
- No `env:` keys are used in the current layout.yml — `$SUBDIR` expansion relies
  on shell environment
