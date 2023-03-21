" https://rbtnn.hateblo.jp/entry/2014/11/30/174749
set encoding=utf-8
scriptencoding utf-8

filetype off
filetype plugin indent off
syntax off

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
set packpath^=~/.vim
if filereadable(expand('~/.vim/vimrc'))
  execute 'source' expand('~/.vim/vimrc')
endif


" --------------------------------------
" Variable
"
"
if system('uname -r') =~ "microsoft"
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
" Option
"
set laststatus=3
set pumblend=30


" --------------------------------------
" Keymap
"
tnoremap <Esc> <C-\><C-n>


" --------------------------------------
" dein.vim
"
if filereadable(expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc/dein.vim'))
  execute 'source' expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc/dein.vim')
endif


" --------------------------------------
" End of setting
"
filetype plugin indent on
syntax enable
if !exists('g:colors_name')
  colorscheme habamax
endif
