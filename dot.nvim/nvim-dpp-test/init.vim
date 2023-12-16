set belloff=all
set nobackup
set noswapfile
set noundofile
set nowritebackup

let s:dpp_path = expand('<sfile>:p:h') .. '/dpp/dpp.vim'
if filereadable(s:dpp_path)
  execute 'source' s:dpp_path
endif

filetype plugin indent on
syntax enable
