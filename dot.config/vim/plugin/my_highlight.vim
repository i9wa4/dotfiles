augroup MyHighlight
  autocmd!
  autocmd VimEnter,BufEnter,WinEnter,FileType *
  \ call my_highlight#highlight()
augroup END
