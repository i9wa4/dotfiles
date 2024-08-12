" Global Variables
let g:mnh_header_level_shift = 1
let g:my_gtd_path = '~/work/gtd.md'->expand()
let g:my_skk_path = '~/work/skk.md'->expand()

call my_filetype#set_tabstop2_lang_list([
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
\ ])

function! MyStatuslineRightTabline() abort
  let l:ret = ''
  " if exists('*my_util#get_last_loaded_local_vimrc_path')
  "   let l:ret ..= 'Cfg:' .. fnamemodify(my_util#get_last_loaded_local_vimrc_path(), ':p:~:h:t')
  " endif
  if empty(&buftype) && (match(&runtimepath, 'vim-get-git-branch-name') >= 0)
    let l:branch_name = branch_name#get_current_branch_name()
    let l:repo_name = branch_name#get_current_repo_root_name()
    if l:branch_name != ''
      " let l:ret ..= ' / ' .. l:repo_name .. ' (' .. l:branch_name .. ')'
      let l:ret ..= ' ' .. '(' .. l:branch_name .. ')'
    endif
  endif
  " let l:ret ..= ' ' .. (has('nvim') ? '[N]' : '[V]')
  return l:ret
endfunction

" Python
if !($PY_VENV_MYENV->empty()) && !($PY_VER_MINOR->empty())
  let g:python3_host_prog = $PY_VENV_MYENV->expand() .. '/bin/python' .. $PY_VER_MINOR
  call my_util#add_path([$PY_VENV_MYENV->expand() .. '/bin'])
endif

" Denops Plugin Development
" let g:denops#debug = 1
" let g:denops_disable_version_check = 1
" set runtimepath^=~/src/github.com/i9wa4/vim-markdown-number-header
