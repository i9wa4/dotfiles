function! utils#source_local_vimrc(path) abort
  " https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html
  " `https://github.com/vim-jp/issues/issues/1176`
  let l:found = findfile('local.vim', escape(a:path, ' ') . ';')
  if !empty(l:found)
    let l:vimrc_path = l:found->expand()->fnamemodify(':p')
    if filereadable(l:vimrc_path)
      execute 'source' l:vimrc_path
    endif
  endif
endfunction


function! utils#toggle_quote() range abort
  let l:all_quoted = v:true
  for l:lnum in range(a:firstline, a:lastline)
    if getline(l:lnum) !~ '^>'
      let l:all_quoted = v:false
      break
    endif
  endfor

  for l:lnum in range(a:firstline, a:lastline)
    let l:line = getline(l:lnum)
    if l:all_quoted
      call setline(l:lnum, substitute(l:line, '^>\s\?', '', ''))
    else
      call setline(l:lnum, '> ' .. l:line)
    endif
  endfor
endfunction


function! utils#send_register() abort
  call system('tmux load-buffer -', @+)
  call system('printf "\033]52;c;%s\007" "$(printf %s '
  \ .. shellescape(@+) .. ' | base64)" > /dev/tty')
endfunction


function! utils#clean_viminfo() abort
  " delete history
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

  " save viminfo
  if has('nvim')
    wshada!
  else
    wviminfo!
  endif
endfunction


function! utils#highlight_define() abort
  highlight HlMS guibg=#FFB6C1 guifg=#000000
  highlight Databricks guibg=#FF3621 guifg=#F9F7F4
  highlight dbt guibg=#FE6703 guifg=#000000

  " substitution for $XDG_CONFIG_HOME/vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " transparent background
  highlight EndOfBuffer   guibg=NONE
  highlight Folded        guibg=NONE
  highlight Identifier    guibg=NONE
  highlight LineNr        guibg=NONE
  highlight NonText       guibg=NONE
  highlight Normal        guibg=NONE
  highlight Special       guibg=NONE
  highlight StatusLine    guibg=NONE
  highlight StatusLineNC  guibg=NONE
  highlight VertSplit     guibg=NONE
endfunction


function! utils#highlight_match() abort
  call clearmatches()

  call matchadd('HlMS', 'HlMS')
  call matchadd('Databricks', 'Databricks')
  call matchadd('dbt', 'dbt')

  call matchadd('HlMS', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|HACK:\|# %%\|\[ \]')
  call matchadd('HlMS', strftime('%Y%m%d',    localtime() + 0 * 24 * 60 * 60))
  call matchadd('HlMS', strftime('%Y-%m-%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('HlMS', strftime('%Y/%m/%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('Databricks', 'Databricks\|databricks')
  call matchadd('dbt', 'dbt')

  if &filetype != 'ddu-ff' && &filetype != 'ddu-ff-filter'
    let w:trailing_space_match_id = matchadd('SpellBad', '　\|\s\+$')
  else
    " Remove trailing space highlight in ddu windows
    if exists('w:trailing_space_match_id')
      silent! call matchdelete(w:trailing_space_match_id)
      unlet w:trailing_space_match_id
    endif
  endif
endfunction
