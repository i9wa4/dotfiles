scriptencoding utf-8

let s:dein_dir = expand('~/.cache/dein')
if has('nvim')
  let s:dein_dir .= '/nvim'
  if !empty($NVIM_APPNAME)
    let s:dein_dir .= '/' . $NVIM_APPNAME
  endif
else
  let s:dein_dir .= '/vim'
endif

if &runtimepath !~# '/dein.vim'
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath+=' . s:dein_repo_dir
endif

if dein#min#load_state(s:dein_dir)
  let s:rc_dir = expand('<sfile>:p:h')
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:rc_dir . '/dein_nolazy.toml', {'lazy': 0})
  call dein#load_toml(s:rc_dir . '/dein_lazy.toml', {'lazy': 1})
  call dein#load_toml(s:rc_dir . '/dein_ddc.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif
