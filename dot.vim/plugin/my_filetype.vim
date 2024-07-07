augroup MyFiletype
  autocmd!
  autocmd BufEnter,FileType * call my_filetype#set()
augroup END
