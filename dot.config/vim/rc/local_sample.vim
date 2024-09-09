" Global Variables
let g:mnh_header_level_shift = 1
let g:my_dict_path = $XDG_CONFIG_HOME->expand() .. '/skk/mydict'
let g:my_gtd_path = '~/work/gtd.md'->expand()
let g:my_temp_path = '~/work/temp.md'->expand()

call my_filetype#set_tabstop2_lang_list([
\   'bash',
\   'css',
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

function! MyStatuslineRightTabline() abort
  let l:ret = ''

  " if exists('*my_util#get_last_loaded_local_vimrc_path')
  "   let l:ret ..= 'Cfg:' .. fnamemodify(my_util#get_last_loaded_local_vimrc_path(), ':p:~:h:t')
  " endif

  " if empty(&buftype) && (match(&runtimepath, 'vim-get-git-branch-name') >= 0)
  "   let l:branch_name = branch_name#get_current_branch_name()
  "   let l:repo_name = branch_name#get_current_repo_root_name()
  "   if l:branch_name != ''
  "     " let l:ret ..= ' / ' .. l:repo_name .. ' (' .. l:branch_name .. ')'
  "     let l:ret ..= ' ' .. '(' .. l:branch_name .. ')'
  "   endif
  " endif

  if match(&runtimepath, 'vim-gin') >= 0
    let l:name = gin#component#worktree#name()
    let l:branch = gin#component#branch#ascii()
    let l:traffic = gin#component#traffic#ascii()

    if !empty(l:name)
      let l:ret ..= ' ' .. l:name
    endif
    if !empty(l:branch)
      let l:ret ..= ' ' .. '(' .. l:branch .. ')'
    endif
    if !empty(l:traffic)
      let l:ret ..= ' ' .. '[' .. l:traffic .. ']'
    endif
  endif

  return l:ret
endfunction

" Python
if !($PY_VENV_MYENV->empty()) && !($PY_VER_MINOR->empty())
  let g:python3_host_prog = $PY_VENV_MYENV->expand() .. '/bin/python' .. $PY_VER_MINOR
  call my_util#add_path([$PY_VENV_MYENV->expand() .. '/bin'])
endif

" Denops Plugin Development
let g:denops#debug = 1
" set runtimepath^=~/src/github.com/i9wa4/vim-markdown-number-header
