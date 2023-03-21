scriptencoding utf-8


function! my_async#my_jobstart(cmd) abort
  let s:cmd = a:cmd
  let s:line_no = 0
  let s:result = []
  if has('nvim')
    " :h channel-callback
    let s:job = jobstart(s:cmd, {
      \   'on_stdout': {
      \     chanid, data, name->function('s:get_msg')(chanid, data)
      \   },
      \   'on_exit': {
      \     chanid, data, name->function('s:exit_cb')(chanid, data)
      \   },
      \ })
  else
    let s:job = job_start(s:cmd, {
      \   'callback': function('s:get_msg'),
      \   'exit_cb': function('s:exit_cb'),
      \ })
  endif
endfunction

function! s:get_msg(ch, msg) abort
  if has('nvim')
    if len(a:msg) > 1
      for l:i in a:msg[:-2]
        let s:line_no += 1
        let l:msg = '[' . s:line_no . '] ' . a:msg[l:i]
        echomsg l:msg
        call add(s:result, l:msg)
      endfor
    endif
  else
    let s:line_no += 1
    let l:msg = '[' . s:line_no . '] ' . a:msg
    echomsg l:msg
    call add(s:result, l:msg)
  endif
endfunction

function! s:exit_cb(job, status) abort
  echomsg s:result[-1] . ' - Job exited.'
endfunction
