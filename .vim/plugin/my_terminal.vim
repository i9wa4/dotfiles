scriptencoding utf-8


" Terminal
if exists('&termwinkey')
  set termwinkey=<C-g>
  tnoremap <Esc> <C-g>n
endif
nnoremap <Plug>(my-terminal) <Nop>
nmap <Space>t <Plug>(my-terminal)
nnoremap <silent> <Plug>(my-terminal)h <Cmd>call my_terminal#split(v:count)<CR>
nnoremap <silent> <Plug>(my-terminal)v <Cmd>call my_terminal#vsplit()<CR>
nnoremap <silent> <Plug>(my-terminal)r <Cmd>call my_terminal#send_cell(v:count, expand('%:p'))<CR>
nnoremap <silent> <Plug>(my-terminal)s <Cmd>call my_terminal#send_cmd(v:count, expand('%:p'))<CR>


augroup MyTerminal
  autocmd!
  autocmd BufEnter * call my_terminal#update_terminal_number()
augroup END
