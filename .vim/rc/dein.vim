scriptencoding utf-8

let s:dein_dir = expand('~/.cache/dein/')
let s:dein_dir .= has('nvim') ? 'nvim' : 'vim'
if &runtimepath !~# '/dein.vim'
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath+=' . s:dein_repo_dir
endif

" let g:dein#install_check_diff = v:true
" let g:dein#types#git#clone_depth = 1

if dein#min#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  let s:rc_dir = expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc') . '/'
  call dein#load_toml(s:rc_dir . 'dein_nolazy.toml', {'lazy': 0})
  call dein#load_toml(s:rc_dir . 'dein_vim_lazy.toml', {'lazy': 1})
  call dein#load_toml(s:rc_dir . 'dein_nvim_lazy.toml', {'lazy': 1})
  call dein#load_toml(s:rc_dir . 'dein_nvim_ddc.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif
