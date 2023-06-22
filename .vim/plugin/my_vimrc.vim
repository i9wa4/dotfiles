scriptencoding utf-8

augroup MyVimrc
  autocmd!
  autocmd BufEnter * call my_vimrc#set_register()
  autocmd BufReadPost * call my_vimrc#restore_cursor()
  autocmd VimEnter,DirChanged * call my_vimrc#source_local_vimrc(expand('<afile>:p'))
  autocmd VimLeave * call my_vimrc#clean_viminfo()
augroup END
