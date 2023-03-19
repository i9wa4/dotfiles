scriptencoding utf-8

" --------------------------------------
" General Function
"
function! vimrc#my_jobstart(cmd, ...) abort
  let l:OnStdout = get(a:, 1, function('s:dummy'))
  let l:OnError = get(a:, 2, function('s:dummy'))
  " :h channel-callback
  if has('nvim')
    call jobstart(a:cmd, {
      \   'on_stdout': {chanid, data, name->l:OnStdout(chanid, data)},
      \   'on_error': {chanid, data, name->l:OnError(chanid, data)},
      \   'stdout_buffered': 1,
      \   'stderror_buffered': 1,
      \ })
  else
    call job_start(a:cmd, {
      \   'out_cb': l:OnStdout,
      \   'err_cb': l:OnError,
      \ })
  endif
endfunction


function! vimrc#callback(ch, data)
  if has('nvim')
    echo a:data[-2]
  else
    echo a:data
  endif
endfunction


function! s:dummy(...) abort
  echo 'Dummy'
endfunction


" --------------------------------------
" Environment
"
function! vimrc#add_path(path_list) abort
  " https://lambdalisue.hatenablog.com/entry/2015/12/25/000046
  if has('unix') || has('mac')
    let l:separator = ":"
  else
    let l:separator = ";"
  endif

  let l:path_list = split($PATH, l:separator)
  for l:item in reverse(a:path_list)
    let l:index = index(l:path_list, l:item)
    if l:index < 0
      call insert(l:path_list, l:item)
    else
      call remove(l:path_list, l:index)
      call insert(l:path_list, l:item)
    endif
  endfor
  let $PATH = join(l:path_list, l:separator)
endfunction


function! vimrc#ft_common() abort
  if !empty(&filetype)
    setlocal nofoldenable
    setlocal autoindent
    setlocal expandtab
    setlocal shiftwidth=4 softtabstop=4 tabstop=4
  endif
endfunction


function! vimrc#source_local_vimrc(path) abort
  if !empty(&buftype)
    return
  endif

  " execute 'lcd' fnamemodify(a:path, ':h')

  " https://github.com/vim-jp/issues/issues/1176
  let l:vimrc_path_list = []
  for l:i in reverse(findfile('local.vim', escape(a:path, ' ') . ';', -1))
    call add(l:vimrc_path_list, fnamemodify(expand(l:i), ':p'))
  endfor

  if filereadable(expand('~/.vim/rc/local_sample.vim'))
    execute 'source' expand('~/.vim/rc/local_sample.vim')
  endif

  for l:i in l:vimrc_path_list
    execute 'source' l:i
  endfor
endfunction


function! vimrc#set_register() abort
  if empty(&buftype)
    let @a = expand('%:p:~')
    let @b = expand('%:p:~:h')
    let @c = expand('%:t')
    let @d = expand('%:t:r')
    let @e = fnamemodify(getcwd(), ':~')
  endif
endfunction

function! vimrc#clear_regisger() abort
  let l:reg_list = split(
    \   'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"',
    \   '\zs'
    \ )
  for r in l:reg_list
    call setreg(r, [])
  endfor
  if has('nvim')
    wshada!
  else
    wviminfo!
  endif
endfunction


" --------------------------------------
" StatusLine/TabLine
"
function! vimrc#last_search_count() abort
  " :help searchcount()
  let result = searchcount(#{recompute: 1, maxcount: 100000})
  if empty(result)
    return ''
  endif
  if result.incomplete ==# 1 " timed out
    return printf(' /%s [?/??]', @/)
  elseif result.incomplete ==# 2 " max count exceeded
    if result.total > result.maxcount
      \ && result.current > result.maxcount
      return printf(' /%s [>%d/>%d]', @/, result.current, result.total)
    elseif result.total > result.maxcount
      return printf(' /%s [%d/>%d]', @/, result.current, result.total)
    endif
  endif
  return printf(' /%s [%d/%d]', @/, result.current, result.total)
endfunction


function! vimrc#statusline() abort
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

  let l:ret = ' '
  let l:ret .= '[' . l:mode_dict[mode()] . (&paste ? '|PASTE' : '') . ']'
  let l:ret .= ((&buftype == 'terminal') ? (' [' . (has('nvim') ? &channel : bufnr()) . ']') : '')
  " let l:ret .= ' %t'
  let l:ret .= ' %f'
  let l:ret .= (&readonly ? ' [RO]' : (&modified ? ' [+]' : ''))
  let l:ret .= '%<'
  let l:ret .= "%="
  let l:ret .= (v:hlsearch ? vimrc#last_search_count(): '')
  let l:ret .= '  ' . '%l/%L:%-2c'
  " let l:ret .= '  ' . 'Ln:%l/%L, Col:%-2c'
  " let l:ret .= '  ' . '%2p' . "%{'\%'}"
  " let l:ret .= '  ' . (&expandtab ? 'Spaces:' : 'TabSize:') . &tabstop
  let l:ret .= '  ' . ((&fileencoding != '') ? &fileencoding : &encoding)
  let l:ret .= '  ' . ((&fileformat == 'doc') ? 'CRLF' : 'LF')
  let l:ret .= '  ' . ((&filetype == '') ? 'no_ft' : &filetype)
  let l:ret .= ' '
  return l:ret
endfunction


function! vimrc#tabline() abort
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
  let l:ret .= fnamemodify(getcwd(), ':~:.')
  if systemlist('git rev-parse --is-inside-work-tree')[0] == 'true'
    " let l:ret .= ' ' . fnamemodify(systemlist('git rev-parse --show-toplevel')[0], ':t')
    let l:ret .= ' (' . systemlist('git symbolic-ref --short HEAD')[0] . ')'
  endif
  " let l:ret .= ' ' . (has('nvim') ? '[N]' : '[V]')
  let l:ret .= ' '
  return l:ret
endfunction


" --------------------------------------
" Highlight
"
function! vimrc#highlight() abort
  highlight ColorColumn term=NONE cterm=NONE ctermfg=NONE ctermbg=Black gui=NONE guifg=NONE guibg=Black
  highlight Error       term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight ErrorMsg    term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight SpellBad    term=NONE cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE guisp=NONE
  highlight VertSplit   term=NONE cterm=NONE ctermfg=White ctermbg=NONE gui=NONE guifg=White guibg=NONE
  highlight MyEmphasis  term=NONE cterm=NONE ctermfg=Black ctermbg=DarkYellow gui=NONE guifg=Black guibg=DarkYellow
  highlight MyError     term=NONE cterm=NONE ctermfg=Black ctermbg=Red gui=NONE guifg=Black guibg=Red
  highlight MySpecial   term=NONE cterm=NONE ctermfg=Red ctermbg=NONE gui=NONE guifg=Red guibg=NONE
  call matchadd('MyEmphasis', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%')
  call matchadd('MyError', '　\|\[ \]')
  call matchadd('MySpecial', '\t\|\s\+$') " [		] 
endfunction


" --------------------------------------
" Terminal
"
function! vimrc#split(size) abort
  if a:size > 0
    execute a:size 'split'
  else
    6split
  endif
  call s:open_terminal()
  wincmd p
endfunction


function! vimrc#vsplit() abort
  vsplit
  call s:open_terminal()
  wincmd p
endfunction


function! vimrc#send_cmd(number, path) abort
  let l:ext = tolower(fnamemodify(a:path, ':e'))
  if l:ext == 'py'
    call s:send(a:number, "python " . a:path)
  elseif l:ext == 'r'
    call s:send(a:number, "Rscript --encoding=utf-8 " . a:path)
  else
    echo l:ext . ' is unavailable.'
  endif
endfunction


function! vimrc#send_cell(number, path) abort
  let l:ext = tolower(fnamemodify(a:path, ':e'))
  if l:ext == 'py'
    let l:cell_delimiter = '# %%'
    let l:line_ini = search(l:cell_delimiter, 'bcnW')
    let l:line_end = search(l:cell_delimiter, 'nW')
    let l:line_ini = l:line_ini ? l:line_ini + 1 : 1
    let l:line_end = l:line_end ? l:line_end - 1 : line("$")
    execute line_ini . ',' . line_end . 'y'
    call s:send(a:number, "%paste")
  else
    echo l:ext . ' is unavailable.'
  endif
endfunction


function! vimrc#jupytext_sync(path) abort
  let l:ipynb_path = fnamemodify(a:path, ':r') . '.ipynb'
  if filereadable(l:ipynb_path)
    let l:cmd = 'jupytext --sync ' . l:ipynb_path
    call vimrc#my_jobstart(l:cmd, function('vimrc#callback'))
  endif
endfunction


let g:my_terminal_number = 0
function! vimrc#update_terminal_number() abort
  if &buftype == 'terminal'
    if has('nvim')
      let g:my_terminal_number = &channel
    else
      let g:my_terminal_number = bufnr()
    endif
  endif
endfunction


function! s:send(number, cmd) abort
  let l:cmd = a:cmd . "\<CR>"
  if (a:number > 0) && (a:number != g:my_terminal_number)
    let l:number = a:number
  else
    let l:number = g:my_terminal_number
  endif

  if has('nvim')
    call chansend(l:number, l:cmd)
  else
    call term_sendkeys(l:number, l:cmd)
  endif
endfunction


function! s:open_terminal() abort
  if has('nvim')
    terminal
  else
    terminal ++curwin
  endif
endfunction
