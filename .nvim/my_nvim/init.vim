scriptencoding utf-8

filetype off
filetype plugin indent off
syntax off

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
set packpath^=~/.vim
let s:vimrc_path = expand('~/.vim/vimrc')
if filereadable(s:vimrc_path)
  execute 'source' s:vimrc_path
endif


" --------------------------------------
" Option
"
set laststatus=3
set pumblend=30


" --------------------------------------
" dein.vim
"
let s:dein_path = expand('<sfile>:p:h') . '/rc/dein.vim'
if filereadable(s:dein_path)
  execute 'source' s:dein_path
endif


" --------------------------------------
" End of setting
"
filetype plugin indent on
syntax enable
if !exists('g:colors_name')
  colorscheme habamax
endif
