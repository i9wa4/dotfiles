scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitute for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight Error         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
  highlight ErrorMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
  highlight SpellBad      term=NONE cterm=underline ctermfg=NONE ctermbg=NONE
  " highlight ColorColumn   term=NONE cterm=NONE ctermfg=NONE ctermbg=Black
  " highlight StatusLine    term=NONE cterm=NONE ctermfg=Gray ctermbg=Black
  " highlight StatusLineNC  term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black
  " highlight TabLine       term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black
  " highlight TabLineFill   term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black
  " highlight TabLineSel    term=NONE cterm=NONE ctermfg=Black ctermbg=Gray
  " highlight VertSplit     term=NONE cterm=NONE ctermfg=DarkGray ctermbg=NONE

  " [ ]
  highlight MyEmphasis term=NONE cterm=NONE ctermfg=Black ctermbg=218 " Pink1
  call matchadd('MyEmphasis', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]')
  call matchadd('MyEmphasis', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis', strftime('%Y%m%d'))
  " 　 
  highlight MyError term=NONE cterm=NONE ctermfg=Black ctermbg=DarkRed
  call matchadd('MyError', '　\|\s\+$')
  " [		]
  highlight MySpecial term=NONE cterm=NONE ctermfg=DarkRed ctermbg=NONE
  call matchadd('MySpecial', '\t')
endfunction
