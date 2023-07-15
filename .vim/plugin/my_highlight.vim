scriptencoding utf-8

augroup MyHighlight
  autocmd!
  autocmd VimEnter,BufEnter * call my_highlight#highlight()
augroup END
