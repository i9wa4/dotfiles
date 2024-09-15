" --------------------------------------
" TabLine
"
function! my_util#tabline() abort
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
function! my_util#add_path(path_list) abort
  " https://lambdalisue.hatenablog.com/entry/2015/12/25/000046
  if has('unix')
    let l:separator = ":"
  else
    let l:separator = ";"
  endif

  let l:path_list = split(getenv('PATH'), l:separator)
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
