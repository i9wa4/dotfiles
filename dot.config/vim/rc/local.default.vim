" Global Variables
let g:mnh_header_level_shift = 1
let g:my_dict_path = $XDG_CONFIG_HOME->expand() .. '/skk/mydict.utf8'
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
call my_util#add_python_venv($PY_VENV_MYENV)

" Denops Plugin Development
" let g:denops#debug = 1
