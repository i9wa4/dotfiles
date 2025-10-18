let g:vim_indent = #{
\   line_continuation: 0
\ }

augroup MyFiletype
  autocmd!
  autocmd FileType * call my_filetype#init()
  autocmd BufNewFile,BufReadPost *.code-workspace,*.tfstate
  \ setfiletype json
  autocmd BufNewFile,BufReadPost *.tf,*.tftpl
  \ setfiletype terraform
  autocmd BufNewFile,BufReadPost *.zshenv,*.zshrc
  \ setfiletype zsh
augroup END
