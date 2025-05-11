function! my_highlight#highlight() abort
  call clearmatches()

  " NOTE: #EBDBB2: Normal guifg for retrobox
  highlight HlEC guifg=#000000 guibg=#DAFFF9
  highlight HlIN guifg=#EBDBB2 guibg=#E6325F
  highlight HlIR guifg=#000000 guibg=#FF8C3C
  highlight HlKM guifg=#EBDBB2 guibg=#EB4682
  highlight HlKR guifg=#EBDBB2 guibg=#198CAA
  highlight HlKT guifg=#000000 guibg=#CDA5FF
  highlight HlMS guifg=#000000 guibg=#FFB6C1
  highlight HlSA guifg=#000000 guibg=#FFD728
  highlight HlSV guifg=#000000 guibg=#C8C3DC

  call matchadd('HlEC', 'HlEC')
  call matchadd('HlIN', 'HlIN')
  call matchadd('HlIR', 'HlIR')
  call matchadd('HlKM', 'HlKM')
  call matchadd('HlKR', 'HlKR')
  call matchadd('HlKT', 'HlKT')
  call matchadd('HlMS', 'HlMS')
  call matchadd('HlSA', 'HlSA')
  call matchadd('HlSV', 'HlSV')

  call matchadd('HlSA', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|HACK:\|# %%\|\[ \]')

  call matchadd('HlEC', strftime('%Y%m%d',    localtime() - 1 * 24 * 60 * 60))
  call matchadd('HlEC', strftime('%Y-%m-%d',  localtime() - 1 * 24 * 60 * 60))
  call matchadd('HlEC', strftime('%Y/%m/%d',  localtime() - 1 * 24 * 60 * 60))
  call matchadd('HlKM', strftime('%Y%m%d',    localtime() + 0 * 24 * 60 * 60))
  call matchadd('HlKM', strftime('%Y-%m-%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('HlKM', strftime('%Y/%m/%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('HlMS', strftime('%Y%m%d',    localtime() + 1 * 24 * 60 * 60))
  call matchadd('HlMS', strftime('%Y-%m-%d',  localtime() + 1 * 24 * 60 * 60))
  call matchadd('HlMS', strftime('%Y/%m/%d',  localtime() + 1 * 24 * 60 * 60))

  " substitution for $XDG_CONFIG_HOME/vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " [		  ]
  highlight clear SpecialKey
  highlight SpecialKey guifg=#606060

  " error
  " highlight clear Error
  " highlight clear ErrorMsg
  call matchadd('Error', '　\|\s\+$')
  " highlight clear SpellBad
  " highlight SpellBad cterm=underline gui=underline

  " cursorline
  highlight clear CursorLine
  highlight CursorLine guibg=#404040

  " transparent background
  " highlight TabLine guibg=NONE
  " highlight TabLineFill guibg=NONE
  highlight EndOfBuffer guibg=NONE
  highlight Folded guibg=NONE
  highlight Identifier guibg=NONE
  highlight LineNr guibg=NONE
  highlight NonText guibg=NONE
  highlight Normal guibg=NONE
  highlight Special guibg=NONE
  highlight StatusLine guibg=NONE
  highlight StatusLineNC guibg=NONE
  highlight VertSplit guibg=NONE
endfunction
