function! my_filetype#set() abort
  if !empty(&buftype)
    return
  endif

  setlocal nofoldenable autoindent expandtab
  setlocal shiftwidth=4 softtabstop=4 tabstop=4
  setlocal spelllang+=cjk spell

  if &diff
    setlocal nospell
  endif

  if index(g:my_filetype#tabstop_two_lang_list, &filetype) >= 0
    setlocal shiftwidth=2 softtabstop=2 tabstop=2
  elseif index([
  \   'go',
  \   'make',
  \ ], &filetype) >= 0
    setlocal noexpandtab
  else
    " Do nothing.
  endif

  " Linter
  if &filetype == 'sh' && executable('shellcheck')
    let &l:makeprg = 'shellcheck -f gcc -x %'
    let &l:errorformat = '%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l:%c: %tote: %m,'
  elseif &filetype == 'dockerfile' && executable('hadolint')
    let &l:makeprg = 'hadolint --no-color %'
    let &l:errorformat = '%f:%l %m'
  else
    " Do nothing.
  endif

  " Formatter
  if &filetype == 'json' && executable('jq')
    let &l:formatprg = 'jq .'
  endif
endfunction
