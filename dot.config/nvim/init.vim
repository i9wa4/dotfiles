set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
set packpath^=~/.vim


" --------------------------------------
" Variable
"
if exists('$WSLENV')
  let g:clipboard = {
    \   'name': 'WslClipboard',
    \   'copy': {
    \      '+': ['sh', '-c', "nkf -sc | clip.exe"],
    \      '*': ['sh', '-c', "nkf -sc | clip.exe"],
    \    },
    \   'paste': {
    \      '+': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    \      '*': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    \   },
    \   'cache_enabled': 0,
    \ }
endif


" --------------------------------------
" vimrc
"
let s:vimrc_path = '~/.vim/vimrc'->expand()
if filereadable(s:vimrc_path)
  execute 'source' s:vimrc_path
endif


" --------------------------------------
" Option
"
" set laststatus=3
set nrformats=unsigned
set wildmenu wildoptions=pum,tagfile wildchar=<Tab>


" --------------------------------------
" dpp.vim
"
let s:dpp_path = '~/.vim/dpp/dpp.vim'->expand()
if filereadable(s:dpp_path) && !exists('*dpp#min#load_state')
  execute 'source' s:dpp_path
endif


" --------------------------------------
" End of setting
"
set background=dark
filetype plugin indent on
syntax enable

if has('termguicolors')
  set termguicolors
endif

if v:version >= 901
  execute 'colorscheme' get(g:, 'colors_name', 'retrobox')
else
  execute 'colorscheme' get(g:, 'colors_name', 'habamax')
endif
