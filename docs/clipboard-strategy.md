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

## 2. Configuration Surfaces

| Surface                         | File                                         | Responsibility                                                      |
| ------------------------------- | -------------------------------------------- | ------------------------------------------------------------------- |
| Vim and Neovim editor behavior  | `config/vim/vimrc`                           | Select Vim registers and define editor clipboard providers          |
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
- Linux and Neovim with clipboard support: `set clipboard^=unnamedplus`

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

tmux cannot guarantee host clipboard access alone. The outer terminal must also
allow clipboard writes, usually OSC 52. If OSC 52 is blocked by the terminal,
`load-buffer -w` still updates tmux's own buffer, but the host clipboard may not
change.

## 5. Provider Order

Prefer this order for editor providers:

| Platform      | Editor | Preferred provider order                                                   |
| ------------- | ------ | -------------------------------------------------------------------------- |
| macOS         | Neovim | Neovim default provider, or explicit `pbcopy` and `pbpaste`                |
| macOS         | Vim    | `v:clipproviders` using `pbcopy` and `pbpaste` when needed                 |
| Linux or WSL2 | Neovim | Neovim default provider, then tmux fallback inside tmux                    |
| Linux or WSL2 | Vim    | `v:clipproviders` using `wl-copy`, `xclip`, `xsel`, then tmux fallback     |

This keeps Neovim simple because Neovim already knows how to auto-detect common
clipboard tools. Vim needs more help when it is built without native clipboard
support but with `+clipboard_provider`.

## 6. Current Vim Complexity

The current `vimrc` clipboard block is long because it handles all of these
cases explicitly:

- macOS Vim with `v:clipproviders`
- macOS Neovim with explicit `g:clipboard`
- Linux Neovim with tmux fallback when `xclip`, `xsel`, and `wl-copy` are absent
- Linux Vim with `v:clipproviders`
- X11 `+` clipboard and `*` primary selection as separate buffers
- Wayland clipboard and primary selection
- tmux fallback as both copy and paste provider

That is complete, but not minimal.

## 7. Minimal Strategy

The preferred simplification path is:

1. Let Neovim auto-detect native providers.
2. Keep explicit provider code mainly for Vim with `v:clipproviders`.
3. Treat `+` as the real target and allow `*` to mirror `+` when simplifying.
4. Keep tmux fallback because it is valuable in WSL2, SSH, and headless terminal
   sessions.
5. Do not preserve X11 primary selection as a hard requirement unless there is
   a real workflow depending on it.

A minimal implementation can use one provider tuple:

```vim
let s:clip = []
if has('mac') && executable('pbcopy')
  let s:clip = ['pb', 'pbcopy', 'pbpaste']
elseif executable('wl-copy')
  let s:clip = ['wl', 'wl-copy', 'wl-paste']
elseif executable('xclip')
  let s:clip = [
  \ 'xclip',
  \ 'xclip -selection clipboard',
  \ 'xclip -selection clipboard -o',
  \ ]
elseif executable('xsel')
  let s:clip = ['xsel', 'xsel --clipboard --input', 'xsel --clipboard --output']
elseif executable('tmux') && !empty($TMUX)
  let s:clip = ['tmux', 'tmux load-buffer -w -', 'tmux save-buffer -']
endif
```

Then `+` and `*` can both call the same copy and paste commands. That drops
primary-selection precision in exchange for a much shorter config.

## 8. Recommended Daily Flow

Use these rules while editing:

- In Vim and Neovim, yank normally and expect the `+` clipboard path to carry
  the text to the host.
- Inside tmux, prefer editor clipboard integration first. If text is only in a
  tmux buffer, press prefix `Y` to push it to the host clipboard.
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

## 10. Design Decision

Keep tmux as a fallback provider. It is the most portable escape hatch for WSL2,
SSH, and terminal-only sessions.

Do not optimize the shared `vimrc` for perfect X11 primary selection behavior
unless that workflow becomes important. The simpler target is:

- `+` means host clipboard.
- `*` may mirror `+`.
- Neovim gets to stay mostly automatic.
- Vim gets one compact `v:clipproviders` path.
