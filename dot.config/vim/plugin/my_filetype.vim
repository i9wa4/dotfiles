augroup MyFiletype
  autocmd!
  autocmd BufEnter,FileType * call my_filetype#init()
  autocmd BufNewFile,BufReadPost *.bashrc,*.profile,*.bash_profile
  \ setfiletype bash
  autocmd BufNewFile,BufReadPost *.zshrc,*.zshenv
  \ setfiletype zsh
  autocmd BufNewFile,BufReadPost *.tf,*.tftpl
  \ setfiletype terraform
  autocmd BufNewFile,BufReadPost *.tfstate
  \ setfiletype json
augroup END
