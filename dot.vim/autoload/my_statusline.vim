scriptencoding utf-8

" --------------------------------------
" StatusLine
"
function! my_statusline#statusline() abort
  " let l:mode_dict = {
  "  \ 'n': 'NORMAL',
  "  \ 'i': 'INSERT',
  "  \ 'R': 'REPLACE',
  "  \ 'v': 'VISUAL',
  "  \ 'V': 'V-LINE',
  "  \ "\<C-v>": 'V-BLOCK',
  "  \ 'S': 'S-LINE',
  "  \ "\<C-s>": 'S-BLOCK',
  "  \ 's': 'SELECT',
  "  \ 'c': 'COMMAND',
  "  \ 't': 'TERMINAL',
  "  \ }

  let l:ret = ''
  " let l:ret ..= '[' .. l:mode_dict[mode()] .. (&paste ? '|PASTE' : '') .. '] '
  " let l:ret ..= ((&buftype == 'terminal') ? ('[' .. (has('nvim') ? &channel : bufnr()) .. '] ') : '')
  " let l:ret ..= '%t '
  " let l:ret ..= '%f '
  " let l:ret ..= (&readonly ? '[RO] ' : (&modified ? '[+] ' : ''))
  let l:ret ..= '%<'
  let l:ret ..= "%="
  let l:ret ..= (v:hlsearch ? s:last_search_count() : '')
  " let l:ret ..= '  ' .. 'Ln:%l/%L Col:%-2c'
  return l:ret
endfunction

function! s:last_search_count() abort
  " :help searchcount()
  if !exists('*searchcount')
    return ''
  endif

  let l:result = searchcount(#{recompute: 1, maxcount: 100000})
  if empty(l:result)
    return ''
  endif
  if l:result.incomplete ==# 1 " timed out
    return printf('[?/?] %s', @/)
  elseif l:result.incomplete ==# 2 " max count exceeded
    if (l:result.total > l:result.maxcount)
      \ && (l:result.current > l:result.maxcount)
      return printf('[>%d/>%d] %s', l:result.current, l:result.total, @/)
    elseif l:result.total > l:result.maxcount
      return printf('[%d/>%d] %s', l:result.current, l:result.total, @/)
    endif
  endif
  return printf('[%d/%d] %s', l:result.current, l:result.total, @/)
endfunction


" --------------------------------------
" TabLine
"
function! my_statusline#tabline() abort
  " https://qiita.com/wadako111/items/755e753677dd72d8036d
  let l:ret = ''
  for l:i in range(1, tabpagenr('$'))
    let l:bufnrs = tabpagebuflist(l:i)
    let l:bufnr = l:bufnrs[tabpagewinnr(l:i) - 1]
    let l:no = l:i
    let l:title = strcharpart(fnamemodify(bufname(l:bufnr), ':t') .. '          ', 0, 10)
    if empty(l:title)
      let l:title = '[No Name]'
    endif
    let l:mod = getbufvar(l:bufnr, '&modified') ? '[+]' : ''

    let l:ret ..= '%' .. l:i .. 'T'
    let l:ret ..= '%#' .. (l:i == tabpagenr() ? 'TabLineSel' : 'TabLine') .. '#'
    let l:ret ..= (((l:i > 1 ) && (l:i > tabpagenr())) ? '|' : '')
    let l:ret ..= '' .. l:no .. ' ' .. l:title .. l:mod .. ''
    let l:ret ..= (((l:i < tabpagenr()) && (l:i < tabpagenr('$'))) ? '|' : '')
    let l:ret ..= '%#TabLineFill#'
  endfor

  let l:ret ..= '%#TabLineFill#%T%=%#TabLineFill#'
  " let l:ret ..= system('. /etc/bash_completion.d/git-prompt && echo $(__git_ps1 " (%s)")')
  let l:ret ..= system('. /etc/bash_completion.d/git-prompt && __git_ps1')
  let l:ret ..= ' ' .. (has('nvim') ? '[N]' : '[V]')
  return l:ret
endfunction
