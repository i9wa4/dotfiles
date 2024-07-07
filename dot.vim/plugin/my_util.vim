augroup MyUtil
  autocmd!
  autocmd BufReadPost * call my_util#restore_cursor()
  autocmd BufNewFile,BufReadPost,BufEnter * call my_util#source_local_vimrc('<afile>:p'->expand())
  autocmd VimEnter * call my_util#source_local_vimrc('<afile>:p'->expand())
  " autocmd VimEnter * call my_util#source_local_vimrc($MYVIMRC->expand())
  autocmd VimLeave * call my_util#clean_viminfo()
augroup END
