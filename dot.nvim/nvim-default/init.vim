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
let s:vimrc_path = expand('~/.vim/vimrc')
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
" End of setting
"
colorscheme retrobox
