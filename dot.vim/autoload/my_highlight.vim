scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitution for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight Error         term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
  highlight ErrorMsg      term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
  highlight SpellBad      term=NONE cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE

  " https://www.ditig.com/256-colors-cheat-sheet
  call clearmatches()

  " [ ]
  "https://www.anarchive-beta.com/entry/2022/07/14/052235
  " Black, Pink1, Sayu
  if has('nvim')
    highlight MyEmphasis1   gui=NONE guifg=#000000 guibg=#ffb6c1
  else
    highlight MyEmphasis1   term=NONE cterm=NONE ctermfg=0 ctermbg=218
  endif
  call matchadd('MyEmphasis1', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]')

  " https://wikiwiki.jp/nijisanji/%E3%82%AB%E3%83%A9%E3%83%BC%E3%82%B3%E3%83%BC%E3%83%89%E3%81%BE%E3%81%A8%E3%82%81
  " Black, LightGoldenrod2, Himawari
  if has('nvim')
    highlight MyEmphasis2   gui=NONE guifg=#000000 guibg=#fbe340
  else
    highlight MyEmphasis2   term=NONE cterm=NONE ctermfg=0 ctermbg=221
  endif
  call matchadd('MyEmphasis2', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis2', strftime('%Y%m%d'))

  " 　 
  highlight MyError       term=NONE cterm=NONE ctermfg=0 ctermbg=88 gui=NONE guifg=#000000 guibg=#870000 " Black, DarkRed
  call matchadd('MyError', '　\|\s\+$')

  " [		]
  highlight MySpecial     term=NONE cterm=NONE ctermfg=88 ctermbg=NONE gui=NONE guifg=#870000 guibg=NONE " DarkRed
  call matchadd('MySpecial', '\t')
endfunction
