scriptencoding utf-8


let s:dein_dir = expand('~/.cache/dein/') . $NVIM_APPNAME
if &runtimepath !~# '/dein.vim'
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath+=' . s:dein_repo_dir
endif

if dein#min#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  let s:rc_dir = expand($XDG_CONFIG_HOME . '/' . $NVIM_APPNAME . '/rc/')
  call dein#load_toml(s:rc_dir . 'dein_nolazy.toml', {'lazy': 0})
  call dein#load_toml(s:rc_dir . 'dein_lazy.toml', {'lazy': 1})
  call dein#load_toml(s:rc_dir . 'dein_ddc.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif
