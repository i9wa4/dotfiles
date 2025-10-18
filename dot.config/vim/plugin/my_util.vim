" let &statusline = ' '->repeat(&columns)
set statusline=%!my_util#statusline()
set tabline=%!my_util#tabline()

augroup MyUtil
  autocmd!
  autocmd BufEnter * checktime
  autocmd BufReadPost * call my_util#restore_cursor()
  " autocmd VimEnter,BufNewFile,BufReadPost,BufEnter *
  autocmd VimEnter *
  \ call my_util#source_local_vimrc('<afile>:p'->expand())
  autocmd VimLeave * call my_util#clean_viminfo()
augroup END
