" Global Variables
let g:mnh_header_level_shift = 1
let g:my_dict_path = $XDG_CONFIG_HOME->expand() .. '/skk/mydict'
let g:my_gtd_path = '~/str/gtd.md'->expand()
let g:my_temp_path = '~/str/temp.md'->expand()

call my_filetype#set_tabstop2_lang_list([
\   'bash',
\   'css',
\   'hcl',
\   'json',
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
\ ])

" Python
if !($PY_VENV_MYENV->empty())
  let g:python3_host_prog = $PY_VENV_MYENV->expand() .. '/bin/python'
  call my_util#add_path([$PY_VENV_MYENV->expand() .. '/bin'])
endif

" Denops Plugin Development
" let g:denops#debug = 1
" set runtimepath^=~/src/github.com/i9wa4/vim-markdown-number-header
