scriptencoding utf-8

if has('nvim')
  tnoremap <Esc> <C-\><C-n>
else
  set termwinkey=<C-g>
  tnoremap <Esc> <C-g>N
endif
nnoremap <Plug>(my-terminal) <Nop>
nmap <Space>t <Plug>(my-terminal)
nnoremap <silent> <Plug>(my-terminal)h :call my_terminal#split(v:count)<CR>
nnoremap <silent> <Plug>(my-terminal)v :<C-u>call my_terminal#vsplit()<CR>
nnoremap <silent> <Plug>(my-terminal)r :<C-u>call my_terminal#send_cell(v:count, expand('%:p'))<CR>
nnoremap <silent> <Plug>(my-terminal)s :<C-u>call my_terminal#send_cmd(v:count, expand('%:p'))<CR>

augroup MyTerminal
  autocmd!
  autocmd BufWinEnter * call my_terminal#update_terminal_number()
augroup END
