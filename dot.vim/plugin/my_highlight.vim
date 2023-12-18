augroup MyHighlight
  autocmd!
  autocmd VimEnter,BufEnter,WinEnter * call my_highlight#highlight()
augroup END
