scriptencoding utf-8

augroup MyVimrc
  autocmd!
  autocmd BufWinEnter * call my_vimrc#set_register()
  autocmd BufReadPost * call my_vimrc#restore_cursor()
  autocmd VimEnter,DirChanged * call my_vimrc#source_local_vimrc(expand('<afile>:p'))
  autocmd VimLeavePre * call my_vimrc#clean_viminfo()
augroup END
