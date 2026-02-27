" ~/.config/vim/vimrc
set runtimepath^=~/.config/vim
set runtimepath+=~/.config/vim/after
set packpath^=~/.config/vim

let s:vimrc_path = $XDG_CONFIG_HOME->expand() .. '/vim/vimrc'
if filereadable(s:vimrc_path)
  execute 'source' s:vimrc_path
endif
