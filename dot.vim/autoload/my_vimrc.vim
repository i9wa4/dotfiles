scriptencoding utf-8

" --------------------------------------
" Viminfo
"
function! my_vimrc#restore_cursor() abort
  if (line("'\"") >= 1) && (line("'\"") <= line("$"))
    execute "normal! g'\""
  endif
endfunction

function! my_vimrc#clean_viminfo() abort
  " delete history
  call histdel("cmd")
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
function! my_vimrc#add_path(path_list) abort
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
function! my_vimrc#set_preload_vimrc(path) abort
  let s:preload_vimrc_path = a:path
endfunction

function! my_vimrc#source_local_vimrc(path) abort
  " https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html
  " https://github.com/vim-jp/issues/issues/1176
  let l:vimrc_path_list = []
  for l:i in reverse(findfile('local.vim', escape(a:path, ' ') . ';', -1))
    call add(l:vimrc_path_list, fnamemodify(expand(l:i), ':p'))
  endfor

  if s:preload_vimrc_path != ''
    call insert(l:vimrc_path_list, s:preload_vimrc_path, 0)
  endif

  for l:i in l:vimrc_path_list
    if filereadable(l:i)
      execute 'source' l:i
    endif
  endfor
endfunction
