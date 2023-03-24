scriptencoding utf-8


augroup MyVimrc
  autocmd!
  " Autoread
  autocmd WinEnter * checktime

  " FileType (order-sensitive)
  autocmd FileType *
    \ if !empty(&filetype)
    \|  setlocal nofoldenable autoindent expandtab
    \|  setlocal shiftwidth=4 softtabstop=4 tabstop=4
    \|endif
  autocmd FileType
    \ css,mermaid,plantuml,sh,toml,vim,yaml
    \ setlocal shiftwidth=2 softtabstop=2 tabstop=2

  " Local Setting
  " https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html
  autocmd VimEnter,DirChanged * call vimrc#source_local_vimrc(expand('<afile>:p'))

  " Mark
  autocmd BufReadPost * call vimrc#restore_cursor()
  autocmd BufReadPost * delmarks a-z

  " Register
  autocmd BufEnter * call vimrc#set_register()

  " Leaving Vim
  autocmd VimLeavePre * call vimrc#clean_viminfo()

  " if !has('nvim') && has('unix') && exists('$WSLENV')
  "   autocmd TextYankPost * call system('clip.exe', system('nkf -sc', @"))
  " endif
augroup END
