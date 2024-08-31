scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitution for $XDG_CONFIG_HOME/vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight clear Error
  highlight clear ErrorMsg
  highlight clear SpellBad
  highlight SpellBad cterm=underline gui=underline

  " cursorline
  highlight CursorLine guibg=#404040

  " transparent background
  highlight EndOfBuffer guibg=NONE
  highlight Folded guibg=NONE
  highlight Identifier guibg=NONE
  highlight LineNr guibg=NONE
  highlight NonText guibg=NONE
  highlight Normal guibg=NONE
  highlight Special guibg=NONE
  highlight VertSplit guibg=NONE

  call clearmatches()

  highlight clear MyIR
  highlight MyIR guifg=#000000 guibg=#FF8C3C
  call matchadd('MyIR', 'MyIR')
  call matchadd('MyIR', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:')

  highlight clear MyMS
  highlight MyMS guifg=#000000 guibg=#FFB6C1
  call matchadd('MyMS', 'MyMS')
  call matchadd('MyMS', '\[ \]\|# %%')
  call matchadd('MyMS', strftime('%Y-%m-%d'))
  call matchadd('MyMS', strftime('%Y/%m/%d'))
  call matchadd('MyMS', strftime('%Y%m%d'))

  highlight clear MyEC
  highlight MyEC guifg=#000000 guibg=#DAFFF9
  call matchadd('MyEC', 'MyEC')
  call matchadd('MyEC', strftime('%Y-%m-%d', localtime() + 24 * 60 * 60))
  call matchadd('MyEC', strftime('%Y/%m/%d', localtime() + 24 * 60 * 60))
  call matchadd('MyEC', strftime('%Y%m%d', localtime() + 24 * 60 * 60))

  " 　		 
  highlight clear MyIN
  highlight MyIN guifg=#FFFFFF guibg=#E6325F
  call matchadd('MyIN', 'MyIN')
  call matchadd('MyIN', '　\|\s\+$')
endfunction
