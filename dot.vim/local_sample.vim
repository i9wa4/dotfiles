scriptencoding utf-8

" Global Variables
let g:my_bookmark_path    = expand('~/work/bookmark.md')
let g:my_gtd_path         = expand('~/work/gtd.md')
let g:my_local_vimrc_path = expand('<sfile>')
let g:my_skk_path         = expand('~/work/skk.md')

" Python
if !(getenv('PY_VENV_MYENV')->empty()) && !(getenv('PY_VER_MINOR')->empty())
  let g:python3_host_prog = expand(getenv('PY_VENV_MYENV') .. '/bin/python' .. getenv('PY_VER_MINOR'))
  call my_vimrc#add_path([expand(getenv('PY_VENV_MYENV') .. '/bin')])
endif

call setenv('PS1', '\n$ ')

" Denops Plugin Development
" let g:denops#debug = 1
" set runtimepath^=~/work/git/markdown-number-header.vim/
