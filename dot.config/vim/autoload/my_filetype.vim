let s:tabstop2_lang_list = []
function! my_filetype#init() abort
  if !empty(&buftype)
    return
  endif

  setlocal nofoldenable autoindent expandtab
  setlocal shiftwidth=4 softtabstop=4 tabstop=4
  setlocal spelllang+=cjk spell

  if &diff
    setlocal nospell
  endif

  if index(s:tabstop2_lang_list, &filetype) >= 0
    setlocal shiftwidth=2 softtabstop=2 tabstop=2
  elseif index([
  \   'go',
  \   'make',
  \ ], &filetype) >= 0
    setlocal noexpandtab
  else
    " Do nothing.
  endif
endfunction

function! my_filetype#set_tabstop2_lang_list(list) abort
  let s:tabstop2_lang_list = a:list
endfunction
