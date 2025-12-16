" Global Variables
let g:mnh_header_level_shift = 7
let g:my_ac_path = '~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/CLAUDE.md'->expand()
let g:my_i0_path = '~/ghq/github.com/i9wa4/internal/docs/00/index.qmd'->expand()
let g:my_tp_path = '~/ghq/github.com/i9wa4/dotfiles/.i9wa4/temp.md'->expand()

" Python
call my_util#add_python_venv('~/ghq/github.com/i9wa4/dotfiles/.venv')
" call my_util#add_python_venv(expand('<sfile>:p:h') .. '/.venv')

" Denops Plugin Development
let g:denops#debug = 1

" Tabline
function! MyStatuslineRightTabline() abort
  return get(g:, 'colors_name', 'default')
endfunction
