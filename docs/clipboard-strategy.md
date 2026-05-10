# Clipboard Strategy

This document describes how clipboard integration should work across Vim,
Neovim, tmux, and host terminals in this dotfiles repo.

## 1. Goal

Clipboard behavior should be boring:

- Yank in Neovim and paste in the host OS.
- Keep Vim's clipboard behavior close to Vim defaults.
- Copy in the host OS and paste in Vim or Neovim.
- Keep the same behavior inside tmux, SSH, Ubuntu, WSL2, and macOS as much as
  the terminal allows.
- Keep editor config understandable. Prefer fewer providers over perfect
  handling of every historical clipboard distinction.

The target is system clipboard integration, not a full model of every selection
buffer on every platform.

The key success case is remote editing from a MacBook. When copying text on the
Ubuntu server, the text should propagate all the way to the local macOS
clipboard so it can be pasted into local Mac apps without an extra transfer
step.

## 2. Configuration Surfaces

| Surface           | File                                         | Responsibility                                                      |
| ----------------- | -------------------------------------------- | ------------------------------------------------------------------- |
| Vim behavior      | `config/vim/vimrc`                           | Keep standalone Vim baseline, netrw mapping, and editor bootstrap   |
| Neovim behavior   | `config/nvim/nvim/init.lua`                  | Configure Neovim registers, yank sync, plugin bootstrap, and UI     |
| tmux behavior     | `nix/home-manager/modules/tmux.nix`          | Pass clipboard data between panes, tmux buffers, terminal, and host |
| Terminal behavior | terminal config and terminal app preferences | Permit OSC 52 clipboard writes when tmux or tools emit them         |

Vim and Neovim intentionally have separate entrypoints. `vimrc` stays small so
standalone Vim is predictable, while Neovim owns its larger editor behavior in
Lua.

## 3. Registers

Use these register meanings:

| Register         | Meaning                                             | Repo policy                                                         |
| ---------------- | --------------------------------------------------- | ------------------------------------------------------------------- |
| unnamed register | Default yank, delete, and paste register            | Keep normal Vim behavior unless `clipboard` redirects it            |
| `+`              | System clipboard                                    | Primary target on Linux, WSL2, and terminal clipboard paths         |
| `*`              | Primary selection on X11, system clipboard on macOS | Nice to preserve when cheap, but not required for minimal strategy  |

The repo currently sets clipboard redirection only in Neovim:

- macOS: `set clipboard^=unnamed`
- Linux and WSL2: `set clipboard^=unnamedplus`

That means ordinary Neovim yanks are expected to reach the OS clipboard on the
normal daily platforms. Vim intentionally keeps its default register behavior.

## 4. tmux Role

tmux is part of the clipboard path, not just a terminal multiplexer.

Current tmux settings:

```tmux
set-option -g set-clipboard on
set-option -g allow-passthrough on
bind-key Y run-shell 'tmux save-buffer - | tmux load-buffer -w -'
```

The responsibilities are:

- `set-clipboard on`
  Lets tmux attempt host clipboard writes when applications or tmux buffers use
  OSC 52 clipboard sequences.
- `allow-passthrough on`
  Allows nested applications to pass selected escape sequences through tmux.
  This matters for terminal-mediated clipboard flows.
- `tmux load-buffer -w -`
  Loads stdin into a tmux buffer and asks tmux to also write it to the external
  clipboard.
- `tmux save-buffer -`
  Reads the current tmux buffer to stdout.
- Prefix `Y`
  Re-sends the current tmux buffer through `load-buffer -w`, useful after tmux
  captured text but did not write it to the host clipboard yet.
- The Neovim register sender
  Sends a Neovim register to `tmux load-buffer -w -`, which is the editor-side
  bridge into this tmux clipboard path.
- Neovim `TextYankPost`
  Mirrors unnamed yanks to `tmux load-buffer -w -` inside tmux, so normal
  yanks such as `yy` participate in the host clipboard path even when the
  normal provider is not the final host clipboard path.

tmux cannot guarantee host clipboard access alone. The outer terminal must also
allow clipboard writes, usually OSC 52. If OSC 52 is blocked by the terminal,
`load-buffer -w` still updates tmux's own buffer, but the host clipboard may not
change.

## 5. Nested tmux over SSH

The main remote workflow is:

```text
MacBook terminal
  -> local macOS tmux
    -> SSH
      -> remote Ubuntu tmux
        -> Vim or Neovim
```

In this shape, a yank from the remote editor reaches the Mac clipboard only if
the clipboard payload can cross every layer:

```text
remote editor clipboard path
  -> remote tmux buffer and OSC 52 write
    -> SSH stream
      -> local tmux accepts or forwards OSC 52
        -> Mac terminal accepts OSC 52
          -> macOS clipboard
```

For this use case, tmux fallback is not just a last resort. It is the most
important portable bridge from a headless Ubuntu server back to the MacBook
clipboard.

The success condition is the Mac clipboard, not the remote clipboard. Updating
only the remote tmux buffer is useful for remote paste, but it is not enough for
the normal MacBook workflow.

The default editor behavior should make ordinary yanks participate in this
path. In Neovim, `yy` on the remote Ubuntu server sends the unnamed register
through the `TextYankPost` tmux mirror. Vim is intentionally not customized for
this path in `vimrc`; use Vim's explicit clipboard registers or tmux copy mode
when editing in Vim.

Both tmux layers should keep:

```tmux
set-option -g set-clipboard on
set-option -g allow-passthrough on
```

The remote Ubuntu tmux needs `set-clipboard on` so `tmux load-buffer -w -` can
emit the clipboard escape sequence toward the SSH client. The local macOS tmux
must not block that sequence before it reaches the outer Mac terminal. The Mac
terminal must also allow clipboard writes from terminal escape sequences.

If remote editor yanks update only the remote tmux buffer, the missing hop is
usually outside the editor. Check in this order:

1. Can the Mac terminal accept OSC 52 clipboard writes?
2. Does local macOS tmux have `set-clipboard` enabled?
3. Does local macOS tmux allow the incoming clipboard sequence from the SSH
   pane?
4. Does remote Ubuntu tmux have `set-clipboard` enabled?
5. Is remote Neovim running the `TextYankPost` hook that mirrors unnamed yanks
   to `tmux load-buffer -w -`?

## 6. Provider Scope

Keep provider ownership narrow:

| Platform      | Editor | Preferred provider behavior                                      |
| ------------- | ------ | ---------------------------------------------------------------- |
| macOS         | Neovim | Neovim default provider, plus tmux mirror inside tmux            |
| macOS         | Vim    | No custom clipboard provider in `vimrc`                          |
| Linux or WSL2 | Neovim | Neovim default provider, plus tmux mirror inside tmux            |
| Linux or WSL2 | Vim    | No custom clipboard provider in `vimrc`                          |

This keeps Neovim simple because Neovim already knows how to auto-detect common
clipboard tools. Vim stays simple because `vimrc` does not own clipboard
policy.

Inside tmux, Neovim also mirrors unnamed yanks through
`tmux load-buffer -w -`. Vim keeps the baseline smaller and relies on explicit
Vim or tmux operations when clipboard transfer is needed.

## 7. Current Editor Model

The current editor config keeps the clipboard model small:

- Neovim uses its built-in provider detection.
- `+` is treated as the real system clipboard target.
- Inside tmux, Neovim unnamed yanks are mirrored to `tmux load-buffer -w -`.
- In Neovim, `<Space>r{register}` can push a named register manually.
- Vim does not define clipboard providers or alter `clipboard`.

## 8. Recommended Daily Flow

Use these rules while editing:

- In Neovim, yank normally and expect the `+` clipboard path to carry the text
  to the host.
- In Vim, use Vim defaults. Reach for explicit clipboard registers or tmux copy
  mode when you need host clipboard transfer.
- Inside tmux, prefer editor clipboard integration first. If text is only in a
  tmux buffer, press prefix `Y` to push it to the host clipboard.
- When editing on the Ubuntu server from a MacBook tmux session, expect the
  remote tmux path to be the bridge back to the Mac clipboard.
- Use normal yanks such as `yy` for the default path. In Neovim, use
  `<Space>r{register}` when a named register must be pushed manually.
- When clipboard writes work in Neovim but not Vim, remember that Vim clipboard
  routing is intentionally not customized by this repo.
- When clipboard writes work in Vim but not Neovim, inspect Neovim provider and
  register state first: `:checkhealth vim.provider` and `:set clipboard?`.
- When clipboard writes work outside tmux but not inside tmux, inspect tmux and
  terminal OSC 52 support before changing editor config.
- When clipboard writes work locally but not over SSH, assume terminal and tmux
  passthrough policy before assuming Vim is wrong.

## 9. Troubleshooting

Run these checks from the same shell where the editor runs:

```sh
nvim --headless +'checkhealth vim.provider' +'qa!'
tmux show-options -g set-clipboard allow-passthrough
```

Inside Vim:

```vim
:set clipboard?
:reg +
```

Inside tmux:

```sh
printf test | tmux load-buffer -w -
tmux save-buffer -
```

If the tmux buffer updates but the host clipboard does not, the missing part is
usually the outer terminal's clipboard permission or OSC 52 support.

For the nested MacBook-to-Ubuntu workflow, run the tmux checks on both hosts.
The remote host proves whether the editor can reach remote tmux. The Mac host
proves whether the SSH pane can reach the Mac terminal clipboard.

## 10. Design Decision

Keep tmux as a fallback provider. It is the most portable escape hatch for WSL2,
SSH, and terminal-only sessions.

Do not optimize the editor config for perfect X11 primary selection behavior
unless that workflow becomes important. The simpler target is:

- `+` means host clipboard in Neovim.
- Neovim gets to stay mostly automatic.
- Vim stays minimal and does not own clipboard policy.
