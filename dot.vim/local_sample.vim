" Global Variables
let g:my_bookmark_path    = '~/work/bookmark.md'->expand()
let g:my_daily_path       = '~/work/daily.md'->expand()
let g:my_gtd_path         = '~/work/gtd.md'->expand()
let g:my_local_vimrc_path = '<sfile>'->expand()
let g:my_skk_path         = '~/work/skk.md'->expand()

" Python
if !($PY_VENV_MYENV->empty()) && !($PY_VER_MINOR->empty())
  let g:python3_host_prog = $PY_VENV_MYENV->expand() .. '/bin/python' .. $PY_VER_MINOR
  call my_vimrc#add_path([$PY_VENV_MYENV->expand() .. '/bin'])
endif

" Denops Plugin Development
" let g:denops#debug = 1
" set runtimepath^=~/work/git/plugins/markdown-number-header.vim/
