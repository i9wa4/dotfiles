let $CACHE = '~/.cache'->expand()
if !$CACHE->isdirectory()
  call mkdir($CACHE, 'p')
endif

function s:init_plugin(plugin)
  " Search from ~/work directory
  let s:dir = '~/work/git/plugins'->expand() .. a:plugin->fnamemodify(':t')
  if !s:dir->isdirectory()
    " Search from $CACHE directory
    let s:dir = $CACHE .. '/dpp/repos/github.com/' .. a:plugin
    if !s:dir->isdirectory()
      " Install plugin automatically.
      " execute 'silent !git clone https://github.com/' .. a:plugin s:dir
      if has('nvim')
        execute '!git clone https://github.com/' .. a:plugin s:dir
      else
        execute 'silent !git clone https://github.com/' .. a:plugin s:dir
      endif
    endif
  endif

  execute 'set runtimepath^='
    \ .. s:dir->fnamemodify(':p')->substitute('[/\\]$', '', '')
endfunction

" NOTE: dpp.vim path must be added
call s:init_plugin('Shougo/dpp-ext-lazy')
call s:init_plugin('Shougo/dpp.vim')


"---------------------------------------------------------------------------
" dpp configurations.
"
" Set dpp base path (required)
const s:dpp_base = '~/.cache/dpp'->expand()
let $BASE_DIR = '<sfile>'->expand()->fnamemodify(':h')

if has('nvim')
  const s:profile = $NVIM_APPNAME
else
  const s:profile = 'vim'
endif

if dpp#min#load_state(s:dpp_base, s:profile)
  " NOTE: denops.vim and dpp plugins must be added
  for s:plugin in [
      \   'Shougo/dpp-ext-installer',
      \   'Shougo/dpp-ext-local',
      \   'Shougo/dpp-ext-packspec',
      \   'Shougo/dpp-ext-toml',
      \   'Shougo/dpp-protocol-git',
      \   'vim-denops/denops.vim',
      \ ]
    call s:init_plugin(s:plugin)
  endfor

  " NOTE: Manual load is needed for neovim
  " Because "--noplugin" is used to optimize.
  if has('nvim')
    runtime! plugin/denops.vim
  endif

  autocmd User DenopsReady
    \ : echohl WarningMsg
    \ | echomsg '[dpp] call make_state()'
    \ | echohl NONE
    \ | call dpp#make_state(s:dpp_base, '$BASE_DIR/dpp.ts'->expand(), s:profile)
else
  call s:init_plugin('vim-denops/denops.vim')

  autocmd BufWritePost *.lua,*.vim,*.toml,*.ts,vimrc,.vimrc
    \ call dpp#check_files(s:profile)
endif

autocmd User Dpp:makeStatePost
  \ : echohl WarningMsg
  \ | echomsg '[dpp] make_state() is done'
  \ | echohl NONE

function DppInstall()
  call dpp#async_ext_action('installer', 'install')
endfunction

function DppUpdate()
  call dpp#async_ext_action('installer', 'update')
endfunction

function DppMakeState()
    call dpp#make_state(s:dpp_base, '$BASE_DIR/dpp.ts'->expand(), s:profile)
endfunction
