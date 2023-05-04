scriptencoding utf-8

let g:my_bookmark_path = expand('~/work/bookmark.md')
let g:my_gtd_path = expand('~/work/gtd.md')
" let g:local_vim_dir = fnamemodify(expand('<sfile>'), ":h:t")
let g:local_vim_dir = 'default'

if !empty('$PY_VENV_MYENV') && !empty('$PY_VER_MINOR')
  let g:python3_host_prog = expand($PY_VENV_MYENV . '/bin/python' . $PY_VER_MINOR)
  call my_vimrc#add_path([expand($PY_VENV_MYENV . '/bin')])
endif

" if has('nvim') && has('unix') && exists('$WSLENV')
"   let g:clipboard = {
"     \   'name': 'WslClipboard',
"     \   'copy': {
"     \      '+': ['sh', '-c', "nkf -sc | clip.exe"],
"     \      '*': ['sh', '-c', "nkf -sc | clip.exe"],
"     \    },
"     \   'paste': {
"     \      '+': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
"     \      '*': 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
"     \   },
"     \   'cache_enabled': 1,
"     \ }
" endif
