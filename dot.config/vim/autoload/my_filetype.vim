function! my_filetype#init() abort
  if !empty(&buftype)
    return
  endif

  setlocal nofoldenable autoindent
  setlocal spelllang+=cjk spell

  if &diff
    setlocal nospell
  endif
endfunction
