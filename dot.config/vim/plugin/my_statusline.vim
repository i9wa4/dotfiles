" set statusline=%F
" set statusline=%t
" set statusline=%{'-'->repeat(&columns)}
set statusline=%{'\ '->repeat(&columns)}
" set statusline=%{my_statusline#last_search_count()}%<%F

set tabline=%!my_statusline#tabline()

augroup MyTerminal
  autocmd!
  autocmd BufEnter * redrawstatus
  autocmd BufEnter * redrawtabline
augroup END
