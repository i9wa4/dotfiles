# Clipboard Strategy

This document describes how clipboard integration should work across Vim,
Neovim, tmux, and host terminals in this dotfiles repo.

## 1. Goal

Clipboard behavior should be boring:

- Yank in Vim or Neovim and paste in the host OS.
- Copy in the host OS and paste in Vim or Neovim.
- Keep the same behavior inside tmux, SSH, Ubuntu, WSL2, and macOS as much as
  the terminal allows.
- Keep `vimrc` understandable. Prefer fewer providers over perfect handling of
  every historical clipboard distinction.

The target is system clipboard integration, not a full model of every selection
buffer on every platform.

The key success case is remote editing from a MacBook. When copying text on the
Ubuntu server, the text should propagate all the way to the local macOS
clipboard so it can be pasted into local Mac apps without an extra transfer
step.

## 2. Configuration Surfaces

| Surface                         | File                                         | Responsibility                                                      |
| ------------------------------- | -------------------------------------------- | ------------------------------------------------------------------- |
| Vim and Neovim editor behavior  | `config/vim/vimrc`                           | Select Vim registers, define editor clipboard providers, sync yanks |
| Neovim bootstrap                | `config/nvim/nvim/init.lua`                  | Source the shared Vim config before Neovim-only plugins             |
| tmux behavior                   | `nix/home-manager/modules/tmux.nix`          | Pass clipboard data between panes, tmux buffers, terminal, and host |
| Terminal behavior               | terminal config and terminal app preferences | Permit OSC 52 clipboard writes when tmux or tools emit them         |

Neovim intentionally shares `config/vim/vimrc`. Clipboard decisions in the Vim
file affect both editors unless guarded by `has('nvim')`.

## 3. Registers

Use these register meanings:

| Register         | Meaning                                             | Repo policy                                                         |
| ---------------- | --------------------------------------------------- | ------------------------------------------------------------------- |
| unnamed register | Default yank, delete, and paste register            | Keep normal Vim behavior unless `clipboard` redirects it            |
| `+`              | System clipboard                                    | Primary target on Linux, WSL2, and terminal clipboard paths         |
| `*`              | Primary selection on X11, system clipboard on macOS | Nice to preserve when cheap, but not required for minimal strategy  |

The repo currently sets:

- macOS: `set clipboard^=unnamed`
- Linux and WSL2: `set clipboard^=unnamedplus` when Neovim, native clipboard,
  or Vim clipboard providers are available

That means ordinary yanks are expected to reach the OS clipboard on the normal
daily platforms.

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
- `SendRegister()` in `vimrc`
  Sends a Vim register to `tmux load-buffer -w -`, which is the editor-side
  bridge into this tmux clipboard path.
- `TextYankPost` in `vimrc`
  Mirrors unnamed yanks to `tmux load-buffer -w -` inside tmux, so normal
  yanks such as `yy` participate in the host clipboard path.

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

In this shape, a yank from remote Vim reaches the Mac clipboard only if the
clipboard payload can cross every layer:

```text
remote Vim provider
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

The default editor behavior should make ordinary Vim yanks participate in this
path. For example, `yy` on the remote Ubuntu server should send the unnamed
register through the `TextYankPost` tmux mirror so it can reach the local Mac
clipboard.

Both tmux layers should keep:

```tmux
set-option -g set-clipboard on
set-option -g allow-passthrough on
```

The remote Ubuntu tmux needs `set-clipboard on` so `tmux load-buffer -w -` can
emit the clipboard escape sequence toward the SSH client. The local macOS tmux
must not block that sequence before it reaches the outer Mac terminal. The Mac
terminal must also allow clipboard writes from terminal escape sequences.

If remote Vim yanks update only the remote tmux buffer, the missing hop is
usually outside Vim. Check in this order:

1. Can the Mac terminal accept OSC 52 clipboard writes?
2. Does local macOS tmux have `set-clipboard` enabled?
3. Does local macOS tmux allow the incoming clipboard sequence from the SSH
   pane?
4. Does remote Ubuntu tmux have `set-clipboard` enabled?
5. Is remote Vim or Neovim running the `TextYankPost` hook that mirrors unnamed
   yanks to `tmux load-buffer -w -`?

## 6. Provider Order

Prefer this order for editor providers:

| Platform      | Editor | Preferred provider behavior                                      |
| ------------- | ------ | ---------------------------------------------------------------- |
| macOS         | Neovim | Neovim default provider, plus tmux mirror inside tmux            |
| macOS         | Vim    | `v:clipproviders` with `pbcopy` and `pbpaste` when needed        |
| Linux or WSL2 | Neovim | Neovim default provider, plus tmux mirror inside tmux            |
| Linux or WSL2 | Vim    | `v:clipproviders` using `wl-copy`, `xclip`, `xsel`, then tmux    |

This keeps Neovim simple because Neovim already knows how to auto-detect common
clipboard tools. Vim needs more help when it is built without native clipboard
support but with `+clipboard_provider`.

Inside tmux, Vim and Neovim also mirror unnamed yanks through
`tmux load-buffer -w -`. This makes `yy` work in the MacBook to SSH to Ubuntu
to tmux workflow even when the editor's normal provider is not the final host
clipboard path.

## 7. Current Vim Model

The current `vimrc` keeps the clipboard model small:

- Neovim uses its built-in provider detection.
- Vim gets one `v:clipproviders` entry when it needs one.
- `+` is treated as the real system clipboard target.
- `*` mirrors `+` for custom providers.
- Inside tmux, unnamed yanks are mirrored to `tmux load-buffer -w -`.
- `<Space>r{register}` can push a named register manually.

The Vim provider selection is one tuple:

```vim
let s:clip = {}
if has('mac') && executable('pbcopy') && executable('pbpaste')
  let s:clip = {'name': 'pb', 'copy': 'pbcopy', 'paste': 'pbpaste'}
elseif executable('wl-copy') && executable('wl-paste')
  let s:clip = {'name': 'wl', 'copy': 'wl-copy', 'paste': 'wl-paste'}
elseif executable('xclip')
  let s:clip = {
  \   'name': 'xclip',
  \   'copy': 'xclip -selection clipboard',
  \   'paste': 'xclip -selection clipboard -o',
  \ }
elseif executable('xsel')
  let s:clip = {
  \   'name': 'xsel',
  \   'copy': 'xsel --clipboard --input',
  \   'paste': 'xsel --clipboard --output',
  \ }
elseif executable('tmux') && !empty($TMUX)
  let s:clip = {
  \   'name': 'tmux',
  \   'copy': 'tmux load-buffer -w -',
  \   'paste': 'tmux save-buffer -',
  \ }
endif
```

This deliberately drops separate X11 primary-selection handling. The tradeoff
is simpler config and more predictable system clipboard behavior.

## 8. Recommended Daily Flow

Use these rules while editing:

- In Vim and Neovim, yank normally and expect the `+` clipboard path to carry
  the text to the host.
- Inside tmux, prefer editor clipboard integration first. If text is only in a
  tmux buffer, press prefix `Y` to push it to the host clipboard.
- When editing on the Ubuntu server from a MacBook tmux session, expect the
  remote tmux provider to be the bridge back to the Mac clipboard.
- Use normal yanks such as `yy` for the default path. Use `<Space>r{register}`
  when a named register must be pushed manually.
- When clipboard writes work in Neovim but not Vim, inspect Vim features first:
  `:echo has('clipboard') exists('v:clipproviders')`.
- When clipboard writes work outside tmux but not inside tmux, inspect tmux and
  terminal OSC 52 support before changing editor config.
- When clipboard writes work locally but not over SSH, assume terminal and tmux
  passthrough policy before assuming Vim is wrong.

## 9. Troubleshooting

Run these checks from the same shell where the editor runs:

```sh
vim --version | grep -E 'clipboard|clipboard_provider|xterm_clipboard'
nvim --headless +'echo has("clipboard") exists("v:clipproviders")' +'qa!'
tmux show-options -g set-clipboard allow-passthrough
```

Inside Vim:

```vim
:echo has('clipboard') exists('v:clipproviders') has('nvim')
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
The remote host proves whether Vim can reach remote tmux. The Mac host proves
whether the SSH pane can reach the Mac terminal clipboard.

## 10. Design Decision

Keep tmux as a fallback provider. It is the most portable escape hatch for WSL2,
SSH, and terminal-only sessions.

Do not optimize the shared `vimrc` for perfect X11 primary selection behavior
unless that workflow becomes important. The simpler target is:

- `+` means host clipboard.
- `*` may mirror `+`.
- Neovim gets to stay mostly automatic.
- Vim gets one compact `v:clipproviders` path.
