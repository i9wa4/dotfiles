function! utils#source_local_vimrc(path) abort
  " https://vim-jp.org/vim-users-jp/2009/12/27/Hack-112.html
  " `https://github.com/vim-jp/issues/issues/1176`
  let l:vimrc_path_list = []
  for l:i in reverse(findfile('local.vim', escape(a:path, ' ') . ';', -1))
    call add(l:vimrc_path_list, l:i->expand()->fnamemodify(':p'))
  endfor

  for l:i in l:vimrc_path_list
    if filereadable(l:i)
      execute 'source' l:i
    endif
  endfor
endfunction


function! utils#highlight() abort
  call clearmatches()

  highlight HlMS guibg=#FFB6C1 guifg=#000000
  highlight Databricks guibg=#FF3621 guifg=#F9F7F4
  highlight dbt guibg=#FE6703 guifg=#000000

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
    let w:trailing_space_match_id = matchadd('Error', '　\|\s\+$')
  else
    " Remove trailing space highlight in ddu windows
    if exists('w:trailing_space_match_id')
      silent! call matchdelete(w:trailing_space_match_id)
      unlet w:trailing_space_match_id
    endif
  endif

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
