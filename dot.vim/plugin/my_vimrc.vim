augroup MyVimrc
  autocmd!
  autocmd BufReadPost * call my_vimrc#restore_cursor()
  " autocmd VimEnter,DirChanged * call my_vimrc#source_local_vimrc(expand('<afile>:p'))
  autocmd DirChanged * call my_vimrc#source_local_vimrc(expand('<afile>:p'))
  autocmd VimEnter * call my_vimrc#source_local_vimrc(expand($MYVIMRC))
  autocmd VimLeave * call my_vimrc#clean_viminfo()
augroup END
