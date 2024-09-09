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
  " let l:ret ..= (v:hlsearch ? my_statusline#last_search_count() : '')
  " let l:ret ..= my_statusline#last_search_count()
  " let l:ret ..= '%t'
  " let l:ret ..= '%'->expand()->fnamemodify(':p:.')
  " let l:ret ..= (&readonly ? '[-]' : (&modified ? '[+]' : ''))
  let l:ret ..= '%<'
  let l:ret ..= "%="
  " let l:ret ..= '  ' .. 'Ln:%l/%L Col:%-3c'
  " let l:ret ..= '  ' .. (&expandtab ? 'Spaces:' : 'TabSize:') .. &tabstop
  " let l:ret ..= '  ' .. ((&fileencoding != '') ? &fileencoding : &encoding)
  " let l:ret ..= '  ' .. ((&fileformat == 'doc') ? 'CRLF' : 'LF')
  " let l:ret ..= '  ' .. ((&filetype == '') ? 'no_ft' : &filetype)
  return l:ret
endfunction

function! my_statusline#last_search_count() abort
  " :help searchcount()
  if !exists('*searchcount') || (&hlsearch == 1 && v:hlsearch == 0)
    return ''
  endif

  let l:result = searchcount(#{recompute: 1, maxcount: 100000})
  if empty(l:result)
    return ''
  endif

  if l:result.incomplete ==# 1 " timed out
    return printf('[?/?] %s | ', @/)
  elseif l:result.incomplete ==# 2 " max count exceeded
    if (l:result.total > l:result.maxcount)
      \ && (l:result.current > l:result.maxcount)
      return printf('[>%d/>%d] %s | ', l:result.current, l:result.total, @/)
    elseif l:result.total > l:result.maxcount
      return printf('[%d/>%d] %s | ', l:result.current, l:result.total, @/)
    endif
  else
    " search completed
    return printf('[%d/%d] %s | ', l:result.current, l:result.total, @/)
  endif
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
    let l:title = fnamemodify(bufname(l:bufnr), ':t')
    if empty(l:title)
      let l:title = '[No Name]'
    endif
    let l:mod = (getbufvar(l:bufnr, '&modified') ? '[+]' : '')
    let l:mod ..= (getbufvar(l:bufnr, '&readonly') ? '[-]' : '')

    let l:content = l:i
    let l:content ..= ' '
    let l:content ..= strcharpart(l:mod .. l:title .. '                    ', 0, 20)

    let l:ret ..= '%' .. l:i .. 'T'
    let l:ret ..= '%#' .. (l:i == tabpagenr() ? 'TabLineSel' : 'TabLine') .. '#'
    let l:ret ..= (((l:i > 1 ) && (l:i > tabpagenr())) ? '|' : '')
    let l:ret ..= l:content
    let l:ret ..= (((l:i < tabpagenr()) && (l:i < tabpagenr('$'))) ? '|' : '')
    let l:ret ..= '%#TabLineFill#'
  endfor

  let l:ret ..= '%#TabLineFill#%T%=%#TabLineFill#'
  if exists('*MyStatuslineRightTabline')
    let l:ret ..= MyStatuslineRightTabline()
  endif

  return l:ret
endfunction
