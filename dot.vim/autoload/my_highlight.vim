scriptencoding utf-8

function! my_highlight#highlight() abort
  " substitution for ~/.vim/after/ftplugin/markdown.vim
  highlight link markdownError Normal
  highlight link markdownItalic Normal

  " override colorscheme setting
  highlight clear Error
  highlight clear ErrorMsg
  highlight clear SpellBad
  highlight SpellBad cterm=underline gui=underline

  " https://www.ditig.com/256-colors-cheat-sheet
  call clearmatches()
  highlight clear MyEmphasis1
  highlight clear MyEmphasis2
  highlight clear MyEmphasis3
  highlight clear MyError
  highlight clear MySpecial

  " [ ]
  "https://www.anarchive-beta.com/entry/2022/07/14/052235
  " Black, Pink1(218), Sayu(#FFB6C1)
  highlight MyEmphasis1 guifg=#000000 guibg=#FFB6C1
  call matchadd('MyEmphasis1', 'TODO:\|FIXME:\|DEBUG:\|NOTE:\|WARNING:\|# %%\|\[ \]')

  " https://wikiwiki.jp/nijisanji/%E3%82%AB%E3%83%A9%E3%83%BC%E3%82%B3%E3%83%BC%E3%83%89%E3%81%BE%E3%81%A8%E3%82%81
  " Black, PaleVioletRed1(211), Saku(#EF9AAF)
  highlight MyEmphasis2 guifg=#000000 guibg=#EF9AAF
  call matchadd('MyEmphasis2', 'J11\|J1_\|J_1\|J__')

  " https://wikiwiki.jp/nijisanji/%E3%82%AB%E3%83%A9%E3%83%BC%E3%82%B3%E3%83%BC%E3%83%89%E3%81%BE%E3%81%A8%E3%82%81
  " Black, LightGoldenrod2(221), Himawari(#FBE340)
  highlight MyEmphasis3 guifg=#000000 guibg=#FBE340
  call matchadd('MyEmphasis3', strftime('%Y-%m-%d'))
  call matchadd('MyEmphasis3', strftime('%Y%m%d'))

  " 　 
  " Black, DarkRed(88,#870000)
  highlight MyError guifg=#000000 guibg=#870000
  call matchadd('MyError', '　\|\s\+$')

  " [		]
  " DarkRed(88,#870000), NONE
  highlight MySpecial guifg=#870000 guibg=NONE
  call matchadd('MySpecial', '\t')
endfunction
