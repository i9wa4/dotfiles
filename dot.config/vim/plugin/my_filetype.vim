let g:vim_indent = #{
\   line_continuation: 0
\ }

augroup MyFiletype
  autocmd!
  autocmd BufEnter,FileType * call my_filetype#init()
  autocmd BufNewFile,BufReadPost *.zshrc,*.zshenv
  \ setfiletype zsh
  autocmd BufNewFile,BufReadPost *.tf,*.tftpl,*.hcl
  \ setfiletype terraform
  autocmd BufNewFile,BufReadPost *.tfstate
  \ setfiletype json
augroup END
