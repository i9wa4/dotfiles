" Global Variables
let g:mnh_header_level_shift = 7
let g:my_i0_path = '~/ghq/github.com/i9wa4/internal/docs/XX/README.md'->expand()
let g:my_i1_path = '~/ghq/github.com/i9wa4/internal/docs/05/README.md'->expand()
let g:my_i2_path = '~/ghq/github.com/i9wa4/internal/docs/06/README.md'->expand()
let g:my_temp_md_path = $HOME->expand() .. '/str/src/temp.md'

" call my_filetype#set_tabstop2_lang_list([
"\   'bash',
"\   'css',
"\   'hcl',
"\   'json',
"\   'liquid',
"\   'mermaid',
"\   'plantuml',
"\   'sh',
"\   'terraform',
"\   'terraform-vars',
"\   'tf',
"\   'toml',
"\   'typescript',
"\   'vim',
"\   'yaml',
"\   'zsh',
"\ ])

" Python
call my_util#add_python_venv('~/ghq/github.com/i9wa4/dotfiles/.venv.main')

" Denops Plugin Development
let g:denops#debug = 1
