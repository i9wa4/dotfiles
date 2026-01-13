function! my_highlight#highlight() abort
  call clearmatches()

  highlight HlEC guibg=#DAFFF9 guifg=#000000
  highlight HlIN guibg=#E6325F guifg=#000000
  highlight HlIR guibg=#FF8C3C guifg=#000000
  highlight HlKM guibg=#EB4682 guifg=#000000
  highlight HlKR guibg=#198CAA guifg=#000000
  highlight HlKT guibg=#CDA5FF guifg=#000000
  highlight HlMS guibg=#FFB6C1 guifg=#000000
  highlight HlSA guibg=#FFD728 guifg=#000000
  highlight HlSV guibg=#C8C3DC guifg=#000000

  call matchadd('HlEC', 'HlEC')
  call matchadd('HlIN', 'HlIN')
  call matchadd('HlIR', 'HlIR')
  call matchadd('HlKM', 'HlKM')
  call matchadd('HlKR', 'HlKR')
  call matchadd('HlKT', 'HlKT')
  call matchadd('HlMS', 'HlMS')
  call matchadd('HlSA', 'HlSA')
  call matchadd('HlSV', 'HlSV')

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
