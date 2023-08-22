scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitution for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight Error         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight ErrorMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
  highlight SpellBad      term=NONE cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE

  call clearmatches()
  " https://www.ditig.com/256-colors-cheat-sheet
  " [ ]
  highlight MyEmphasis    term=NONE cterm=NONE ctermfg=0 ctermbg=218 gui=NONE guifg=#000000 guibg=#ffafd7 " Black, Pink1
  call matchadd('MyEmphasis', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]')
  call matchadd('MyEmphasis', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis', strftime('%Y%m%d'))
  " 　 
  highlight MyError       term=NONE cterm=NONE ctermfg=0 ctermbg=88 gui=NONE guifg=#000000 guibg=#870000 " Black, DarkRed
  call matchadd('MyError', '　\|\s\+$')
  " [		]
  highlight MySpecial     term=NONE cterm=NONE ctermfg=88 ctermbg=NONE gui=NONE guifg=#870000 guibg=NONE " DarkRed
  call matchadd('MySpecial', '\t')
endfunction
