# vde-layout Internals

Short reference for vde-layout config resolution and preset structure.

## 1. Config Resolution

- Binary: user-local npm/global package path, commonly
  `$HOME/.local/lib/node_modules/vde-layout/dist/index.mjs`
- Config loaded from `$VDE_CONFIG_PATH` env var, or default XDG path:
  `$XDG_CONFIG_HOME/vde/layout.yml` or `$HOME/.config/vde/layout.yml`
- `$XDG_CONFIG_HOME/vde` is Home Manager-managed; the layout file resolves to
  `dotfiles/config/vde/layout.yml`

## 2. Preset Definitions (layout.yml)

| Preset   | windowMode     | Panes                                                                   |
| -------- | -------------- | ----------------------------------------------------------------------- |
| main     | current-window | informational Postman pane and vde-monitor; no Postman service          |
| dev      | current-window | editor pane and independent agent                                       |
| preset-p | new-window     | messenger, orchestrator, worker, worker-alt, approver, guardian, critic |
| preset-w | new-window     | the same roles, with the configured Claude/Codex mapping                |

Team commands use `postman-agent ROLE -- CLIENT ... @postman-prompt`.
The launcher verifies its native pane, sets the role title, and replaces the
literal placeholder with the common/selected role instructions. Preserve the
client's explicit model, effort and runtime flags. POP does not inject a role
prompt. Each team preset includes messenger; do not prepend a separate legacy
messenger preset. Resolve exact layout/model settings from current source.

## 3. Key Behavioral Notes

- Env var references in command strings are NOT interpolated by vde-layout —
  they are passed as-is to `tmux send-keys` and expanded by the destination
  pane's shell
- `delay` field (ms) is honored before sending agent command per pane
- Pane title set via `tmux select-pane -T <title>` after split-window
