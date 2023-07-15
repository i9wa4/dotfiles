scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitute for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight Error         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight ErrorMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight SpellBad      term=NONE cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE guisp=NONE
  highlight ColorColumn   term=NONE cterm=NONE ctermfg=NONE ctermbg=Black gui=NONE guifg=NONE guibg=Black
  highlight StatusLine    term=NONE cterm=NONE ctermfg=Gray ctermbg=Black gui=NONE guifg=Gray guibg=Black
  highlight StatusLineNC  term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black gui=NONE guifg=DarkGray guibg=Black
  highlight TabLine       term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black gui=NONE guifg=DarkGray guibg=Black
  highlight TabLineFill   term=NONE cterm=NONE ctermfg=DarkGray ctermbg=Black gui=NONE guifg=DarkGray guibg=Black
  highlight TabLineSel    term=NONE cterm=NONE ctermfg=Black ctermbg=Gray gui=NONE guifg=Black guibg=DarkGray
  highlight VertSplit     term=NONE cterm=NONE ctermfg=DarkGray ctermbg=NONE gui=NONE guifg=DarkGray guibg=NONE

  " [ ]
  highlight MyEmphasis term=NONE cterm=NONE ctermfg=Black ctermbg=DarkYellow gui=NONE guifg=Black guibg=DarkYellow
  call matchadd('MyEmphasis', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]')
  call matchadd('MyEmphasis', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis', strftime('%Y%m%d'))
  " 　 
  highlight MyError term=NONE cterm=NONE ctermfg=Black ctermbg=DarkRed gui=NONE guifg=Black guibg=DarkRed
  call matchadd('MyError', '　\|\s\+$')
  " [		]
  highlight MySpecial term=NONE cterm=NONE ctermfg=DarkRed ctermbg=NONE gui=NONE guifg=Red guibg=NONE
  call matchadd('MySpecial', '\t')
endfunction
