" https://rbtnn.hateblo.jp/entry/2014/11/30/174749
set encoding=utf-8
scriptencoding utf-8

filetype off
filetype plugin indent off
syntax off

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
set packpath^=~/.vim
execute 'source' expand('~/.vim/vimrc')

" --------------------------------------
" Variable
"
"
if system('uname -r') =~ "microsoft"
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
    \   'cache_enabled': 1,
    \ }
endif
" let g:netrw_home = expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME)


" --------------------------------------
" Option
"
set laststatus=3
set pumblend=30


" --------------------------------------
" Keymap
"
tnoremap <Esc> <C-\><C-n>
nnoremap <silent> <Plug>(my-edit)v <Cmd>execute 'edit' expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/init.vim')<CR>


" --------------------------------------
" dein.vim
"
let s:dein_dir = expand('~/.cache/dein')
let s:dein_dir .= '/' . $NVIM_APPNAME
if &runtimepath !~# '/dein.vim'
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath+=' . s:dein_repo_dir
endif

if dein#min#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  let s:rc_dir = expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc') . '/'
  call dein#load_toml(s:rc_dir . 'dein_nolazy.toml', {'lazy': 0})
  call dein#load_toml(s:rc_dir . 'dein_lazy.toml', {'lazy': 1})
  call dein#load_toml(s:rc_dir . 'dein_ddc.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

filetype plugin indent on
syntax enable
if !exists('g:colors_name')
  colorscheme slate
endif
