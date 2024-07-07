" Global Variables
let g:my_gtd_path         = '~/work/gtd.md'->expand()
let g:my_local_vimrc_path = '<sfile>'->expand()
let g:my_skk_path         = '~/work/skk.md'->expand()
let g:my_filetype#tabstop_two_lang_list = [
\   'bash',
\   'css',
\   'liquid',
\   'mermaid',
\   'plantuml',
\   'sh',
\   'terraform',
\   'terraform-vars',
\   'tf',
\   'toml',
\   'typescript',
\   'vim',
\   'yaml',
\   'zsh',
\ ]

" Python
if !($PY_VENV_MYENV->empty()) && !($PY_VER_MINOR->empty())
  let g:python3_host_prog = $PY_VENV_MYENV->expand() .. '/bin/python' .. $PY_VER_MINOR
  call my_util#add_path([$PY_VENV_MYENV->expand() .. '/bin'])
endif

" Denops Plugin Development
" let g:denops#debug = 1
" set runtimepath^=~/work/plugins/markdown-number-header.vim
