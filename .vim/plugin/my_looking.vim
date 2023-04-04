scriptencoding utf-8

set statusline=%!my_looking#statusline()
set tabline=%!my_looking#tabline()

augroup MyLooking
  autocmd!
  " Highlight
  " autocmd BufEnter * call my_looking#highlight()
  autocmd VimEnter,BufNewFile,BufRead * call my_looking#highlight()
augroup END
