" --------------------------------------
" TabLine
"
function! my_util#tabline() abort
  let l:tab_length = 25
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

    let l:tabname_i = (l:tab_no_i - 1) .. ':' .. l:mod_i .. l:bufname_i
    let l:tabname_i = strcharpart(l:tabname_i .. repeat(' ', l:tab_length), 0, l:tab_length)

    let l:ret ..= '%' .. l:tab_no_i .. 'T'
    let l:ret ..= '%#' .. (l:tab_no_i == tabpagenr() ? 'TabLineSel' : 'TabLine') .. '#'
    let l:ret ..= l:tabname_i
    let l:ret ..= '%#TabLine#|'
  endfor

  let l:ret ..= '%#TabLine#%T%=%#TabLineFill#'
  if exists('*MyStatuslineRightTabline')
    let l:ret ..= MyStatuslineRightTabline()
  endif
  let l:ret ..= ' ' .. (has('nvim') ? '[N]' : '[V]')

  return l:ret
endfunction


" --------------------------------------
" StatusLine
"
function! my_util#statusline() abort
  let l:status = '%'->expand()->fnamemodify(':~')
  " let l:status = '%t'
  " let l:status ..= '%<%='
  " let l:status ..= 'Ln %l/%L, Col %-4c'
  " let l:status ..= (&expandtab ? 'Spaces ' : 'TabSize ') .. &tabstop
  " let l:status ..= '  ' .. ((&fileencoding != '') ? &fileencoding : &encoding)
  " let l:status ..= '  ' .. ((&fileformat == 'doc') ? 'CRLF' : 'LF')
  " let l:status ..= '  ' .. ((&filetype == '') ? 'no_ft' : &filetype)
  return l:status
endfunction


" --------------------------------------
" Viminfo
"
function! my_util#restore_cursor() abort
  if (line("'\"") >= 1) && (line("'\"") <= line("$"))
    execute "normal! g'\""
  endif
endfunction


function! my_util#clean_viminfo() abort
  " delete history
  " call histdel("cmd")
  call histdel("search")
  call histdel("expr")
  call histdel("input")
  call histdel("debug")

  " delete registers
  let l:reg_list = split(
    \   'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"',
    \   '\zs'
    \ )
  for l:r in l:reg_list
    call setreg(l:r, [])
  endfor

  " delete marks
  delmarks!
  delmarks A-Z0-9

  " save vininfo
  if has('nvim')
    wshada!
  else
    wviminfo!
  endif
endfunction


" --------------------------------------
" Environment
"
let s:preload_vimrc_path = ''
let s:last_loaded_local_vimrc_path = ''


function! my_util#source_local_vimrc(path) abort
  " https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html
  " https://github.com/vim-jp/issues/issues/1176
  let l:vimrc_path_list = []
  for l:i in reverse(findfile('local.vim', escape(a:path, ' ') . ';', -1))
    call add(l:vimrc_path_list, l:i->expand()->fnamemodify(':p'))
  endfor

  call insert(l:vimrc_path_list, s:preload_vimrc_path, 0)

  let l:loaded_vimrc_path_list = []
  for l:i in l:vimrc_path_list
    if filereadable(l:i)
      execute 'source' l:i
      let s:last_loaded_local_vimrc_path = l:i
      call extend(l:loaded_vimrc_path_list, [l:i])
    endif
  endfor
endfunction


function! my_util#set_preload_vimrc(path) abort
  let s:preload_vimrc_path = a:path
endfunction


function! my_util#get_last_loaded_local_vimrc_path() abort
  return s:last_loaded_local_vimrc_path
endfunction


function! my_util#add_path(path_list) abort
  " https://lambdalisue.hatenablog.com/entry/2015/12/25/000046
  if has('unix')
    let l:separator = ":"
  else
    let l:separator = ";"
  endif

  let l:path_list = uniq(split(getenv('PATH'), l:separator))
  for l:item in reverse(a:path_list)
    let l:index = index(l:path_list, l:item)
    if l:index < 0
      call insert(l:path_list, l:item)
    else
      call remove(l:path_list, l:index)
      call insert(l:path_list, l:item)
    endif
  endfor
  call setenv('PATH', join(l:path_list, l:separator))
endfunction


function! my_util#add_python_venv(venv_path) abort
  if !(a:venv_path->empty())
    let g:python3_host_prog = a:venv_path->expand() .. '/bin/python'
    call my_util#add_path([a:venv_path->expand() .. '/bin'])
  endif
endfunction
