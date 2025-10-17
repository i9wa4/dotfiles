function! my_highlight#highlight() abort
  call clearmatches()

  call matchadd('WildMenu', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|HACK:\|# %%\|\[ \]')
  call matchadd('WildMenu', strftime('%Y%m%d',    localtime() + 0 * 24 * 60 * 60))
  call matchadd('WildMenu', strftime('%Y-%m-%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('WildMenu', strftime('%Y/%m/%d',  localtime() + 0 * 24 * 60 * 60))

  " substitution for $XDG_CONFIG_HOME/vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  if &filetype != 'ddu-ff' && &filetype != 'ddu-ff-filter'
    let w:trailing_space_match_id = matchadd('Error', '　\|\s\+$')
  else
    " Remove trailing space highlight in ddu windows
    if exists('w:trailing_space_match_id')
      silent! call matchdelete(w:trailing_space_match_id)
      unlet w:trailing_space_match_id
    endif
  endif

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
