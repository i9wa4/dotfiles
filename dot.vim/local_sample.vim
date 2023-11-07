scriptencoding utf-8

" Global Variables
let g:my_bookmark_path    = expand('~/work/git/fragment/md/bookmark.md')
let g:my_gtd_path         = expand('~/work/git/fragment/md/gtd.md')
let g:my_local_vimrc_path = expand(expand('<sfile>'))
let g:my_skk_path         = expand('~/work/skk.md')

" Python
if !empty($PY_VENV_MYENV) && !empty($PY_VER_MINOR)
  let g:python3_host_prog = expand($PY_VENV_MYENV .. '/bin/python' .. $PY_VER_MINOR)
  call my_vimrc#add_path([expand($PY_VENV_MYENV .. '/bin')])
endif

" Denops Plugin Development
" let g:denops#debug = 1
" set runtimepath^=~/work/git/markdown-number-header.vim/