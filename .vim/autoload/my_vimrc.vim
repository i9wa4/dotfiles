scriptencoding utf-8

" --------------------------------------
" Viminfo
"
function! my_vimrc#restore_cursor() abort
  if (line("'\"") >= 1) && (line("'\"") <= line("$"))
    execute "normal! g'\""
  endif
endfunction

function! my_vimrc#set_register() abort
  if empty(&buftype)
    let @a = expand('%:p:~')
    let @b = expand('%:p:~:h')
    let @c = expand('%:t')
    let @d = expand('%:t:r')
    let @e = fnamemodify(getcwd(), ':~')
  endif
endfunction

function! my_vimrc#clean_viminfo() abort
  " delete marks
  delmarks!
  delmarks A-Z0-9

  " delete registers
  let l:reg_list = split(
    \   'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"',
    \   '\zs'
    \ )
  for l:r in l:reg_list
    call setreg(l:r, [])
  endfor

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

function! my_vimrc#source_local_vimrc(path) abort
  " https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html
  " https://github.com/vim-jp/issues/issues/1176
  let l:vimrc_path_list = []
  for l:i in reverse(findfile('local.vim', escape(a:path, ' ') . ';', -1))
    call add(l:vimrc_path_list, fnamemodify(expand(l:i), ':p'))
  endfor

  call insert(l:vimrc_path_list, expand('~/.vim/rc/local_sample.vim'), 0)

  for l:i in l:vimrc_path_list
    if filereadable(l:i)
      execute 'source' l:i
    endif
  endfor
endfunction
