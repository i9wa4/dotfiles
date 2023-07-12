scriptencoding utf-8

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
set packpath^=~/.vim


" --------------------------------------
" Variable
"
if has('nvim') && has('unix') && exists('$WSLENV') && !exists('$TMUX')
  let g:clipboard = {
    \   'name': 'WslClipboard',
    \   'copy': {
    \      '+': ['sh', '-c', "nkf -sc | clip.exe"],
    \      '*': ['sh', '-c', "nkf -sc | clip.exe"],
    \    },
    \   'paste': {
    \      '+': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    \      '*': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    \   },
    \   'cache_enabled': 1,
    \ }
endif


" --------------------------------------
" dein.vim
"
let s:dein_path = expand('<sfile>:p:h') . '/rc/dein.vim'
if filereadable(s:dein_path)
  execute 'source' s:dein_path
endif


" --------------------------------------
" vimrc
"
let s:vimrc_path = expand('~/.vim/vimrc')
if filereadable(s:vimrc_path)
  execute 'source' s:vimrc_path
endif


" --------------------------------------
" Option
"
" set laststatus=3
set nrformats=unsigned


" --------------------------------------
" End of setting
"
colorscheme habamax
