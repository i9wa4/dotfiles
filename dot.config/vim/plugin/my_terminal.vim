if has('nvim')
  tnoremap <Esc> <C-\><C-n>
else
  set termwinkey=<C-g>
  tnoremap <Esc> <C-g>N
endif

nnoremap <Plug>(my-terminal) <Nop>
nmap <Space>t <Plug>(my-terminal)
nnoremap <Plug>(my-terminal)h :<C-u>call my_terminal#split(v:count, '%:p:h'->expand())<CR>
nnoremap <Plug>(my-terminal)r :<C-u>call my_terminal#send_cell(v:count, '%:p'->expand())<CR>
nnoremap <Plug>(my-terminal)s :<C-u>call my_terminal#send_cmd(v:count, '%:p'->expand())<CR>
nnoremap <Plug>(my-terminal)v :<C-u>call my_terminal#vsplit('%:p:h'->expand())<CR>

augroup MyTerminal
  autocmd!
  autocmd BufEnter * call my_terminal#update_terminal_number()
augroup END
