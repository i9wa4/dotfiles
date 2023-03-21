scriptencoding utf-8


function! my_terminal#split(size) abort
  if a:size > 0
    execute a:size 'split'
  else
    6split
  endif
  call s:open_terminal()
  wincmd p
endfunction

function! my_terminal#vsplit() abort
  vsplit
  call s:open_terminal()
  wincmd p
endfunction

function! my_terminal#send_cmd(number, path) abort
  let l:ext = tolower(fnamemodify(a:path, ':e'))
  if l:ext == 'py'
    call s:send(a:number, "python " . a:path)
  elseif l:ext == 'r'
    call s:send(a:number, "Rscript --encoding=utf-8 " . a:path)
  else
    echo l:ext . ' is unavailable.'
  endif
endfunction

function! my_terminal#send_cell(number, path) abort
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

let s:terminal_number = 0
function! my_terminal#update_terminal_number() abort
  if &buftype == 'terminal'
    if has('nvim')
      let s:terminal_number = &channel
    else
      let s:terminal_number = bufnr()
    endif
  endif
endfunction

function! s:send(number, cmd) abort
  let l:cmd = a:cmd . "\<CR>"
  if (a:number > 0) && (a:number != s:terminal_number)
    let l:number = a:number
  else
    let l:number = s:terminal_number
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
