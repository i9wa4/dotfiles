set belloff=all
set nobackup
set noswapfile
set noundofile
set nowritebackup

let g:denops#debug = 1

augroup MyAutoCmd
  autocmd!
augroup END

let s:dpp_path = expand('<sfile>:p:h') .. '/rc/dpp.vim'
if filereadable(s:dpp_path)
  execute 'source' s:dpp_path
endif

filetype plugin indent on
syntax enable
set termguicolors
execute 'colorscheme' get(g:, 'colors_name', 'retrobox')
