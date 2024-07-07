" Global Variables
let g:my_gtd_path = '~/work/gtd.md'->expand()
let g:my_skk_path = '~/work/skk.md'->expand()
let g:mnh_header_level_shift = 1

" Python
if !($PY_VENV_MYENV->empty()) && !($PY_VER_MINOR->empty())
  let g:python3_host_prog = $PY_VENV_MYENV->expand() .. '/bin/python' .. $PY_VER_MINOR
  call my_util#add_path([$PY_VENV_MYENV->expand() .. '/bin'])
endif

" Denops Plugin Development
let g:denops#debug = 1
" set runtimepath^=~/work/plugins/markdown-number-header.vim
