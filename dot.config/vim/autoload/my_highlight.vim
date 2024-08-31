scriptencoding utf-8

function! my_highlight#highlight() abort
  call clearmatches()

  highlight MyHlEC guifg=#000000 guibg=#DAFFF9
  highlight MyHlIN guifg=#000000 guibg=#E6325F
  highlight MyHlIR guifg=#000000 guibg=#FF8C3C
  highlight MyHlKM guifg=#000000 guibg=#EB4682
  highlight MyHlMS guifg=#000000 guibg=#FFB6C1
  highlight MyHlSR guifg=#000000 guibg=#2887FF

  call matchadd('MyHlEC', 'MyHlEC')
  call matchadd('MyHlIN', 'MyHlIN')
  call matchadd('MyHlIR', 'MyHlIR')
  call matchadd('MyHlKM', 'MyHlKM')
  call matchadd('MyHlMS', 'MyHlMS')
  call matchadd('MyHlSR', 'MyHlSR')

  call matchadd('MyHlEC', strftime('%Y%m%d',    localtime() + 0 * 24 * 60 * 60))
  call matchadd('MyHlEC', strftime('%Y-%m-%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('MyHlEC', strftime('%Y/%m/%d',  localtime() + 0 * 24 * 60 * 60))
  call matchadd('MyHlIN', '　\|\s\+$')
  call matchadd('MyHlIR', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:')
  call matchadd('MyHlMS', '\[ \]\|# %%')
  call matchadd('MyHlSR', strftime('%Y%m%d',    localtime() + 1 * 24 * 60 * 60))
  call matchadd('MyHlSR', strftime('%Y-%m-%d',  localtime() + 1 * 24 * 60 * 60))
  call matchadd('MyHlSR', strftime('%Y/%m/%d',  localtime() + 1 * 24 * 60 * 60))

  " substitution for $XDG_CONFIG_HOME/vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " error
  highlight clear Error
  highlight clear ErrorMsg
  highlight clear SpellBad
  highlight SpellBad cterm=underline gui=underline

  " cursorline
  highlight clear CursorLine
  highlight CursorLine guibg=#404040

  " [		  ]
  highlight clear SpecialKey
  highlight SpecialKey guifg=#606060

  " transparent background
  highlight EndOfBuffer guibg=NONE
  highlight Folded guibg=NONE
  highlight Identifier guibg=NONE
  highlight LineNr guibg=NONE
  highlight NonText guibg=NONE
  highlight Normal guibg=NONE
  highlight Special guibg=NONE
  highlight VertSplit guibg=NONE
endfunction
