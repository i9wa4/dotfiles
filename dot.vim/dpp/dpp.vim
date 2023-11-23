scriptencoding utf-8

call setenv('CACHE', expand('~/.cache'))
if !(getenv('CACHE')->isdirectory())
  call mkdir(getenv('CACHE'), 'p')
endif

for s:plugin in [
  \   'Shougo/dpp.vim',
  \   'vim-denops/denops.vim',
  \ ]->filter({ _, val->&runtimepath !~# '/' .. val->fnamemodify(':t') })
  " Search from current directory
  let s:dir = s:plugin->fnamemodify(':t')->fnamemodify(':p')
  if !(s:dir->isdirectory())
    " Search from $CACHE directory
    let s:dir = getenv('CACHE') .. '/dpp/repos/github.com/' .. s:plugin
    if !(s:dir->isdirectory())
      execute 'silent !git clone https://github.com/' .. s:plugin s:dir
    endif
  endif

  if s:plugin->fnamemodify(':t') ==# 'dpp.vim'
    execute 'set runtimepath^='
          \ .. s:dir->fnamemodify(':p')->substitute('[/\\]$', '', '')
  endif
endfor



" Set dpp base path (required)
const s:dpp_base = '~/.cache/dpp/'

" Set dpp source path (required)
const s:dpp_src = '~/.cache/dpp/repos/github.com/Shougo/dpp.vim'
const s:denops_src = '~/.cache/dpp/repos/github.com/vim-denops/denops.vim'

" Set dpp runtime path (required)
execute 'set runtimepath^=' .. s:dpp_src

if dpp#min#load_state(s:dpp_base)
  " NOTE: dpp#make_state() requires denops.vim
  execute 'set runtimepath^=' .. s:denops_src
  autocmd User DenopsReady
  \ call dpp#make_state(s:dpp_base, '~/dotfiles/dot.vim/dpp/dpp.ts')
endif
