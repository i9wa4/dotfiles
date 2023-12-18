augroup MyVimrc
  autocmd!
  autocmd BufReadPost * call my_vimrc#restore_cursor()
  autocmd DirChanged * call my_vimrc#source_local_vimrc('<afile>:p'->expand())
  autocmd VimEnter * call my_vimrc#source_local_vimrc($MYVIMRC->expand())
  autocmd VimLeave * call my_vimrc#clean_viminfo()
augroup END
