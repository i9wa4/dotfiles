scriptencoding utf-8

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
set packpath^=~/.vim


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
set laststatus=3
set nrformats=unsigned
set pumblend=30


" --------------------------------------
" End of setting
"
colorscheme habamax
