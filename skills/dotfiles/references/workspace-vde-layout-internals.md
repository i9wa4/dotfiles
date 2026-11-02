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

Team presets start Codex/Claude directly without injecting an initial message.
vde-layout sets native pane role titles; preserve the client's explicit model,
effort and runtime flags. Full POP archives supply common and recipient-role
instructions. Each team preset
includes messenger; do not prepend a separate legacy messenger preset. Resolve
exact layout/model settings from current source.

## 3. Native workspace directory at team boot

Use the vp/vw snippet expansion from config/zsh/snippet.zsh for team starts.
Its __snippet_vde_team helper runs once before vde-layout: it selects the
caller's native socket/session, sets session_path to physical pwd through a
finite control client, verifies the result, then starts the requested preset.
The control client has ignore-size/read-only/no-output flags, does not update
the client environment, consumes closed stdin and exits; it is not a daemon
or a model-message injector. Existing team roles block duplicate boot/rebinding;
a generic agent blocks a change to its native root. This guard matches the
roles owned by these dotfiles presets, not a generic Postman role taxonomy.

Postman intentionally reads native session_path rather than each command's
cwd. Creating a session in HOME then navigating to a repository does not
update that field. Before this boot fix, separate repositories could both be
reported as workspace ~ and the later one correctly refused another live
owner. Never fix that by deleting its state or bypassing ownership checks.
Ordinary later cd leaves the selected native root and mailbox unchanged.
Direct vde-layout invocation bypasses this preparation; it is suitable when
the session was already created in the intended directory with new-session -c.

## 4. Key Behavioral Notes

- Env var references in command strings are NOT interpolated by vde-layout —
  they are passed as-is to `tmux send-keys` and expanded by the destination
  pane's shell
- `delay` field (ms) is honored before sending agent command per pane
- Pane title set via `tmux select-pane -T <title>` after split-window
