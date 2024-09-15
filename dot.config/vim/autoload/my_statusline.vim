" --------------------------------------
" StatusLine
"
function! my_statusline#statusline() abort
  let l:mode_dict = {
  \ 'n': 'NORMAL',
  \ 'i': 'INSERT',
  \ 'R': 'REPLACE',
  \ 'v': 'VISUAL',
  \ 'V': 'V-LINE',
  \ "\<C-v>": 'V-BLOCK',
  \ 'S': 'S-LINE',
  \ "\<C-s>": 'S-BLOCK',
  \ 's': 'SELECT',
  \ 'c': 'COMMAND',
  \ 't': 'TERMINAL',
  \ }

  let l:ret = ''
  let l:ret ..= '[' .. l:mode_dict[mode()] .. (&paste ? '|PASTE' : '') .. '] '
  let l:ret ..= ((&buftype == 'terminal') ? ('[' .. (has('nvim') ? &channel : bufnr()) .. '] ') : '')
  let l:ret ..= my_statusline#last_search_count()
  let l:ret ..= '%f'
  let l:ret ..= (&readonly ? '[-]' : (&modified ? '[+]' : ''))
  let l:ret ..= '%<'
  let l:ret ..= "%="
  let l:ret ..= '  ' .. 'Ln:%l/%L Col:%-3c'
  let l:ret ..= '  ' .. (&expandtab ? 'Spaces:' : 'TabSize:') .. &tabstop
  let l:ret ..= '  ' .. ((&fileencoding != '') ? &fileencoding : &encoding)
  let l:ret ..= '  ' .. ((&fileformat == 'doc') ? 'CRLF' : 'LF')
  let l:ret ..= '  ' .. ((&filetype == '') ? 'no_ft' : &filetype)
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
    let l:tab_no_i = l:i
    let l:bufnr_i = tabpagebuflist(l:tab_no_i)[tabpagewinnr(l:tab_no_i) - 1]

    let l:mod_i = (getbufvar(l:bufnr_i, '&modified') ? '[+]' : '')
    let l:mod_i ..= (getbufvar(l:bufnr_i, '&readonly') ? '[-]' : '')

    let l:bufname_i = fnamemodify(bufname(l:bufnr_i), ':t')
    if empty(l:bufname_i)
      let l:bufname_i = '[No Name]'
    endif

    let l:tabname_i = l:tab_no_i .. ' ' .. l:mod_i .. l:bufname_i
    let l:tabname_i = strcharpart(l:tabname_i .. '               ', 0, 15)

    let l:ret ..= '%' .. l:tab_no_i .. 'T'
    let l:ret ..= '%#' .. (l:tab_no_i == tabpagenr() ? 'TabLineSel' : 'TabLine') .. '#'
    let l:ret ..= l:tabname_i
    let l:ret ..= '%#TabLine#|'
  endfor

  let l:ret ..= '%#TabLine#%T%=%#TabLineFill#'
  if exists('*MyStatuslineRightTabline')
    let l:ret ..= MyStatuslineRightTabline()
  endif

  return l:ret
endfunction
