scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitution for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  " highlight clear Error
  " highlight clear ErrorMsg
  highlight clear SpellBad
  highlight SpellBad cterm=underline gui=underline

  call clearmatches()

  highlight clear MyEmphasis1
  highlight MyEmphasis1 guifg=#000000 guibg=#FFB6C1
  call matchadd('MyEmphasis1', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis1', strftime('%Y%m%d'))

  highlight clear MyEmphasis2
  highlight MyEmphasis2 guifg=#000000 guibg=#EF9AAF
  call matchadd('MyEmphasis2', 'NOTE:\|WARNING:\|# %%')

  " [ ]
  highlight clear MyEmphasis3
  highlight MyEmphasis3 guifg=#000000 guibg=#FBE340
  call matchadd('MyEmphasis3', 'TODO:\|FIXME:\|DEBUG:\|\[ \]')
  call matchadd('MyEmphasis3', strftime('%Y-%m-%d', localtime() + 24 * 60 * 60))
  call matchadd('MyEmphasis3', strftime('%Y%m%d', localtime() + 24 * 60 * 60))

  " 　 
  " Black, DarkRed(88,#870000)
  highlight clear MyError
  highlight MyError guifg=#000000 guibg=#870000
  call matchadd('MyError', '　\|\s\+$')

  " [		]
  " DarkRed(88,#870000), NONE
  " highlight clear MySpecial
  " highlight MySpecial guifg=#870000 guibg=NONE
  " call matchadd('MySpecial', '\t')

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
