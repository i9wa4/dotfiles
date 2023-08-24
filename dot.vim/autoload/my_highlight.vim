scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitution for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight clear Error
  highlight clear ErrorMsg
  highlight clear SpellBad
  highlight SpellBad      cterm=underline gui=underline

  " https://www.ditig.com/256-colors-cheat-sheet
  call clearmatches()
  highlight clear MyEmphasis1
  highlight clear MyEmphasis2
  highlight clear MyError
  highlight clear MySpecial

  " [ ]
  "https://www.anarchive-beta.com/entry/2022/07/14/052235
  " Black, Pink1, Sayu
  if has('nvim')
    highlight MyEmphasis1   guifg=#000000 guibg=#ffb6c1
  else
    highlight MyEmphasis1   ctermfg=0 ctermbg=218
  endif
  call matchadd('MyEmphasis1', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]\|J11\|J1x\|Jx1\|Jxx')

  " https://wikiwiki.jp/nijisanji/%E3%82%AB%E3%83%A9%E3%83%BC%E3%82%B3%E3%83%BC%E3%83%89%E3%81%BE%E3%81%A8%E3%82%81
  " Black, LightGoldenrod2, Himawari
  if has('nvim')
    highlight MyEmphasis2   guifg=#000000 guibg=#fbe340
  else
    highlight MyEmphasis2   ctermfg=0 ctermbg=221
  endif
  call matchadd('MyEmphasis2', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis2', strftime('%Y%m%d'))

  " 　 
  highlight MyError       ctermfg=0 ctermbg=88 guifg=0 guibg=88 " Black, DarkRed
  call matchadd('MyError', '　\|\s\+$')

  " [		]
  highlight MySpecial     ctermfg=88 ctermbg=NONE guifg=88 guibg=NONE " DarkRed
  call matchadd('MySpecial', '\t')
endfunction
