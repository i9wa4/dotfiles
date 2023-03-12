" https://rbtnn.hateblo.jp/entry/2014/11/30/174749
set encoding=utf-8
scriptencoding utf-8

filetype off
filetype plugin indent off
syntax off

if filereadable(expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/vimrc'))
  execute 'source' expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/vimrc')
endif


" --------------------------------------
" Variable
"
let g:clipboard = {
  \   'name': 'WslClipboard',
  \   'copy': {
  \      '+': 'clip.exe',
  \      '*': 'clip.exe',
  \    },
  \   'paste': {
  \      '+': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  \      '*': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  \   },
  \   'cache_enabled': 1,
  \ }
let g:netrw_home = expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME)


" --------------------------------------
" Option
"
" set pumblend=10
set laststatus=3


" --------------------------------------
" Autocommand
"
augroup MyTextYank
  autocmd!
  autocmd TextYankPost * let @+ = @"
augroup END


" --------------------------------------
" Keymap
"
tnoremap <Esc> <C-\><C-n>
nnoremap <silent> <Plug>(my-edit)v
  \ <Cmd>execute 'edit' expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/vimrc')<CR>


" --------------------------------------
" dein.vim
"
if filereadable(expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc/dein.vim'))
  execute 'source' expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc/dein.vim')
endif

filetype plugin indent on
syntax enable
if !exists('g:colors_name')
  colorscheme slate
endif
