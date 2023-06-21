scriptencoding utf-8

" --------------------------------------
" StatusLine
"
function! my_looking#last_search_count() abort
  " :help searchcount()
  if !exists('*searchcount')
    return '*'
  endif

  let l:result = searchcount(#{recompute: 1, maxcount: 100000})
  if empty(l:result)
    return ''
  endif
  if l:result.incomplete ==# 1 " timed out
    return printf(' /%s [?/??]', @/)
  elseif l:result.incomplete ==# 2 " max count exceeded
    if l:result.total > l:result.maxcount
      \ && l:result.current > l:result.maxcount
      return printf(' /%s [>%d/>%d]', @/, l:result.current, l:result.total)
    elseif l:result.total > l:result.maxcount
      return printf(' /%s [%d/>%d]', @/, l:result.current, l:result.total)
    endif
  endif
  return printf(' /%s [%d/%d]', @/, l:result.current, l:result.total)
endfunction

function! my_looking#statusline() abort
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

  " let l:ret = ' '
  let l:ret = ''
  " let l:ret .= '[' . l:mode_dict[mode()] . (&paste ? '|PASTE' : '') . '] '
  let l:ret .= ((&buftype == 'terminal') ? ('[' . (has('nvim') ? &channel : bufnr()) . '] ') : '')
  let l:ret .= '%t '
  " let l:ret .= '%f '
  let l:ret .= (&readonly ? '[RO] ' : (&modified ? '[+] ' : ''))
  let l:ret .= '%<'
  let l:ret .= "%="
  let l:ret .= (v:hlsearch ? my_looking#last_search_count() . ' ' : '')
  let l:ret .= '  ' . '%l/%L:%-2c'
  " let l:ret .= '  ' . 'Ln:%l/%L Col:%-2c'
  " let l:ret .= '  ' . '%2p' . "%{'\%'}"
  let l:ret .= '  ' . (&expandtab ? 'Spaces:' : 'TabSize:') . &tabstop
  let l:ret .= '  ' . ((&fileencoding != '') ? &fileencoding : &encoding)
  let l:ret .= '  ' . ((&fileformat == 'doc') ? 'CRLF' : 'LF')
  let l:ret .= '  ' . ((&filetype == '') ? 'no_ft' : &filetype)
  let l:ret .= '  ' . (has('nvim') ? 'N' : 'V')
  " let l:ret .= ' '
  return l:ret
endfunction


" --------------------------------------
" TabLine
"
function! my_looking#tabline() abort
  " https://qiita.com/wadako111/items/755e753677dd72d8036d
  let l:ret = ''
  for l:i in range(1, tabpagenr('$'))
    let l:bufnrs = tabpagebuflist(l:i)
    let l:bufnr = l:bufnrs[tabpagewinnr(l:i) - 1]
    let l:no = l:i
    let l:title = strcharpart(fnamemodify(bufname(l:bufnr), ':t'), 0, 20)
    if empty(l:title)
      let l:title = '[No Name]'
    endif
    let l:mod = getbufvar(l:bufnr, '&modified') ? '[+]' : ''

    let l:ret .= '%' . l:i . 'T'
    let l:ret .= '%#' . (l:i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let l:ret .= (((l:i > 1 ) && (l:i > tabpagenr())) ? '|' : '')
    let l:ret .= ' ' . l:no . ' ' . l:title . l:mod . ' '
    let l:ret .= (((l:i < tabpagenr()) && (l:i < tabpagenr('$'))) ? '|' : '')
    let l:ret .= '%#TabLineFill#'
  endfor

  let l:ret .= '%#TabLineFill#%T%=%#TabLineFill#'
  let l:ret .= 'CWD:' . fnamemodify(getcwd(), ':~:.')
  if systemlist('git rev-parse --is-inside-work-tree')[0] == 'true'
    " let l:ret .= ' ' . fnamemodify(systemlist('git rev-parse --show-toplevel')[0], ':t')
    let l:ret .= '(' . systemlist('git symbolic-ref --short HEAD')[0] . ')'
  endif
  if exists('g:local_vim_setting_name')
    let l:ret .= '  ' . 'Cfg:' . g:local_vim_setting_name
  endif
  " let l:ret .= ' '
  return l:ret
endfunction


" --------------------------------------
" Highlight
"
function! my_looking#highlight() abort
  " substitute for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight ColorColumn   term=NONE cterm=NONE ctermfg=NONE ctermbg=Black gui=NONE guifg=NONE guibg=Black
  highlight Error         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight ErrorMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight SpellBad      term=NONE cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE guisp=NONE
  highlight StatusLine    term=NONE cterm=NONE ctermfg=Gray ctermbg=Black gui=NONE guifg=Gray guibg=Black
  highlight StatusLineNC  term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black gui=NONE guifg=DarkGray guibg=Black
  highlight TabLine       term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black gui=NONE guifg=DarkGray guibg=Black
  highlight TabLineFill   term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black gui=NONE guifg=DarkGray guibg=Black
  highlight TabLineSel    term=NONE cterm=NONE ctermfg=Black ctermbg=Gray gui=NONE guifg=Black guibg=DarkGray
  highlight VertSplit     term=NONE cterm=NONE ctermfg=DarkGray ctermbg=NONE gui=NONE guifg=DarkGray guibg=NONE

  " [ ]
  highlight MyEmphasis term=NONE cterm=NONE ctermfg=Black ctermbg=DarkYellow gui=NONE guifg=Black guibg=DarkYellow
  call matchadd('MyEmphasis', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]')
  call matchadd('MyEmphasis', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis', strftime('%Y%m%d'))
  " 　 
  highlight MyError term=NONE cterm=NONE ctermfg=Black ctermbg=DarkRed gui=NONE guifg=Black guibg=DarkRed
  call matchadd('MyError', '　\|\s\+$')
  " [		]
  highlight MySpecial term=NONE cterm=NONE ctermfg=DarkRed ctermbg=NONE gui=NONE guifg=Red guibg=NONE
  call matchadd('MySpecial', '\t')
endfunction
