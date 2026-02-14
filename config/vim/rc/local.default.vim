" Global Variables
let g:mnh_header_level_shift = 7
let g:my_aa_path = '~/ghq/github.com/i9wa4/dotfiles/config/agents/AGENTS.md'->expand()
let g:my_i0_path = '~/ghq/github.com/i9wa4/internal/work/00/index.qmd'->expand()
let g:my_i1_path = '~/ghq/github.com/i9wa4/internal/work/05/index.qmd'->expand()
let g:my_i2_path = '~/ghq/github.com/i9wa4/internal/work/07/index.qmd'->expand()

" Python
call my_util#add_python_venv('~/ghq/github.com/i9wa4/dotfiles/.venv')
" call my_util#add_python_venv(expand('<sfile>:p:h') .. '/.venv')

" Denops Plugin Development
let g:denops#debug = 1

" Tabline
function! MyStatuslineRightTabline() abort
  return get(g:, 'colors_name', 'default')
endfunction
