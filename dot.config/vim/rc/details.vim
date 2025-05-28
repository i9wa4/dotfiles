" --------------------------------------
" Variable
"
let g:markdown_recommended_style = 0
let g:netrw_banner = 0
let g:netrw_dirhistmax = 0
let g:netrw_hide = 0
let g:netrw_home = $XDG_CACHE_HOME->expand()
let g:netrw_liststyle = 0

let g:auto_reload = timer_start(
\   1000,
\   {-> execute('silent! checktime')},
\   {'repeat': -1}
\ )


" --------------------------------------
" hook_source
"
call my_util#set_preload_vimrc($XDG_CONFIG_HOME->expand() .. '/vim/rc/local.default.vim')

" --------------------------------------
" Option
"
" Edit
set backspace=indent,eol,start
set completeopt=menuone,noinsert,noselect
set fileencodings=utf-8,euc-jp,cp932
set fileformat=unix
set fileformats=unix,dos,mac
set hidden
set nofoldenable autoindent expandtab
set nrformats=unsigned
set shiftwidth=4 softtabstop=4 tabstop=4
set virtualedit=block

" Search
if executable('rg')
  let &grepprg = 'rg --vimgrep --no-heading'
  " let &grepprg = 'rg --vimgrep --no-heading --no-ignore --hidden'
  set grepformat=%f:%l:%c:%m
endif
set hlsearch
set ignorecase
set incsearch
set shortmess+=c
set shortmess-=S
set smartcase
set wrapscan

" View
set ambiwidth=double
" space:\\u2423,extends:\\u00BB,precedes:\\u00AB
set list listchars=space:␣,tab:>-,trail:~,nbsp:%,extends:»,precedes:«
set nowrap
set number
set relativenumber
set signcolumn=number

" Window
set noequalalways
set pumheight=10
set splitbelow
set splitright
set wildmenu wildoptions=pum,tagfile wildchar=<Tab>

" CommandLine
set cmdheight=1
set noshowcmd

" StatusLine
set laststatus=0
set noshowmode


" TabLine
set showtabline=2

" Highlight
set cursorcolumn
set cursorline
set diffopt=internal,filler,algorithm:histogram,indent-heuristic
set showmatch matchtime=1 matchpairs+=\<:\>

" Abbreviation
" :w' --> :w
cnoreabbrev w' w


" --------------------------------------
" Keymap
"
nnoremap gf gF

" https://zenn.dev/mattn/articles/83c2d4c7645faa
nmap <SID>g <Nop>
nmap gj gj<SID>g
nmap gk gk<SID>g
nnoremap <script> <SID>gj gj<SID>g
nnoremap <script> <SID>gk gk<SID>g
" nnoremap <expr> j (v:count == 0) ? 'gj' : 'j'
" nnoremap <expr> k (v:count == 0) ? 'gk' : 'k'
" xnoremap <expr> j ((v:count == 0) && (mode() ==# 'v')) ? 'gj' : 'j'
" xnoremap <expr> k ((v:count == 0) && (mode() ==# 'v')) ? 'gk' : 'k'

" Insert Mode
" i_CTRL-T Insert one indent
" i_CTRL-D Delete one indent
inoremap ,today <C-r>=strftime('%Y-%m-%d')<CR>
inoremap ,now <C-r>=strftime('%Y-%m-%d %X +0900')<CR>

" Location List
command! Lprevious  try | lprevious | catch | llast   | catch | endtry
command! Lnext      try | lnext     | catch | lfirst  | catch | endtry
nnoremap <C-p> :Lprevious<CR>
nnoremap <C-n> :Lnext<CR>

" Resize Window
" https://zenn.dev/mattn/articles/83c2d4c7645faa
nmap <C-w>H <C-w><<SID>ws
nmap <C-w>J <C-w>-<SID>ws
nmap <C-w>K <C-w>+<SID>ws
nmap <C-w>L <C-w>><SID>ws
nmap <SID>ws <Nop>
nnoremap <script> <SID>wsH <C-w><<SID>ws
nnoremap <script> <SID>wsJ <C-w>-<SID>ws
nnoremap <script> <SID>wsK <C-w>+<SID>ws
nnoremap <script> <SID>wsL <C-w>><SID>ws

" https://lambdalisue.hatenablog.com/entry/2015/12/25/000046
" Edit
nnoremap <Plug>(my-Edit) <Nop>
nmap <Space>e <Plug>(my-Edit)
nnoremap <Plug>(my-Edit)r <Cmd>%s/\r$//e<CR>
nnoremap <Plug>(my-Edit)s <Cmd>%s/\s\+$//e<CR>
nnoremap <Plug>(my-Edit)n <Cmd>%s/\%ua0//e<CR>

" Filer
nnoremap <Plug>(my-Filer) <Nop>
nmap <Space>f <Plug>(my-Filer)
nnoremap <Plug>(my-Filer)c <Cmd>15Lexplore<CR>
nnoremap <Plug>(my-Filer)cd <Cmd>execute 'cd' fnamemodify(finddir('.git', escape(expand(getcwd()), ' ') .. ';', 1), ':h')<CR>
nnoremap <Plug>(my-Filer)i0 <Cmd>execute 'edit' g:my_i0_path<CR>
nnoremap <Plug>(my-Filer)i1 <Cmd>execute 'edit' g:my_i1_path<CR>
nnoremap <Plug>(my-Filer)i2 <Cmd>execute 'edit' g:my_i2_path<CR>
nnoremap <Plug>(my-Filer)l <Cmd>execute 'edit' my_util#get_last_loaded_local_vimrc_path()<CR>
nnoremap <Plug>(my-Filer)o <Cmd>execute '15Lexplore' '%:p:h'->expand()<CR>
nnoremap <Plug>(my-Filer)t <Cmd>execute 'edit' g:my_tp_path<CR>
nnoremap <Plug>(my-Filer)v <Cmd>execute 'edit' $MYVIMRC<CR>

" eNcoding
nnoremap <Plug>(my-eNcoding) <Nop>
nmap <Space>n <Plug>(my-eNcoding)
nnoremap <Plug>(my-eNcoding)ec <Cmd>setlocal fileencoding=cp932<CR>
nnoremap <Plug>(my-eNcoding)ee <Cmd>setlocal fileencoding=euc-jp<CR>
nnoremap <Plug>(my-eNcoding)eu <Cmd>setlocal fileencoding=utf-8<CR>
nnoremap <Plug>(my-eNcoding)fd <Cmd>edit ++fileformat=dos<CR>
nnoremap <Plug>(my-eNcoding)fu <Cmd>edit ++fileformat=unix<CR>
nnoremap <Plug>(my-eNcoding)nc <Cmd>edit ++encoding=cp932<CR>
nnoremap <Plug>(my-eNcoding)ne <Cmd>edit ++encoding=euc-jp<CR>
nnoremap <Plug>(my-eNcoding)nu <Cmd>edit ++encoding=utf-8<CR>

" Switch
nnoremap <Plug>(my-Switch) <Nop>
nmap <Space>s <Plug>(my-Switch)
nnoremap <Plug>(my-Switch)b <Cmd>setlocal scrollbind! scrollbind?<CR>
nnoremap <Plug>(my-Switch)l <Cmd>setlocal list! list?<CR>
nnoremap <Plug>(my-Switch)n <Cmd>setlocal number! number?<CR>
nnoremap <Plug>(my-Switch)p <Cmd>setlocal paste! paste?<CR>
nnoremap <Plug>(my-Switch)r <Cmd>setlocal relativenumber! relativenumber?<CR>
nnoremap <Plug>(my-Switch)s <Cmd>setlocal spell! spell?<CR>
nnoremap <Plug>(my-Switch)t <Cmd>setlocal expandtab! expandtab?<CR>
nnoremap <Plug>(my-Switch)w <Cmd>setlocal wrap! wrap?<CR>


" --------------------------------------
" Command
"
command! -nargs=? C call s:copy2clip(<q-args>)
function s:copy2clip(...) abort
  if a:0 >= 1
    call setreg('+', getreg(a:1))
  else
    call setreg('+', getreg('"'))
  endif
endfunction

command! -nargs=? CW call s:copy2clip_wsl(<q-args>)
function s:copy2clip_wsl(...) abort
  if a:0 >= 1
    if has('win32unix')
      call system('clip.exe', getreg(a:1))
    else
      call system('clip.exe', system('nkf -sc', getreg(a:1)))
    endif
  else
    if has('win32unix')
      call system('clip.exe', getreg('"'))
    else
      call system('clip.exe', system('nkf -sc', getreg('"')))
    endif
  endif
endfunction

command! CreateLocalVimrc
\   call system('echo "\" ~/ghq/github.com/i9wa4/dotfiles/dot.config/vim/rc/local.default.vim" > ./local.vim')
\|  call system('echo "let g:mnh_header_level_shift = 1" >> ./local.vim')


" --------------------------------------
" Autocommand
"
function! s:set_register() abort
  if empty(&buftype)
    call setreg('a', '%'->expand()->fnamemodify(':p'))
    call setreg('b', '%'->expand()->fnamemodify(':p:~'))
    call setreg('c', '%'->expand()->fnamemodify(':p:~:t'))

    let l:status = (&expandtab ? 'Spaces ' : 'TabSize ') .. &tabstop
    let l:status ..= '  ' .. ((&fileencoding != '') ? &fileencoding : &encoding)
    let l:status ..= '  ' .. ((&fileformat == 'doc') ? 'CRLF' : 'LF')
    let l:status ..= '  ' .. ((&filetype == '') ? 'no_ft' : &filetype)
    call setreg('z', l:status)
  endif
endfunction

function! s:my_asyncjob_on_save() abort
  if (&filetype == 'python') || ('%:p:e'->expand() == 'ipynb')
    let l:ipynb_path = '%:p:r'->expand() .. '.ipynb'
    if filereadable(l:ipynb_path) && executable('jupytext')
      " call my_async#jobstart('jupytext --set-formats ipynb,py:percent --sync ' .. l:ipynb_path)
      call my_async#jobstart('jupytext --set-formats ipynb,md --sync ' .. l:ipynb_path)
    endif
  endif
endfunction

augroup MyVimrc
  autocmd!
  autocmd BufEnter * call s:set_register()
  " autocmd BufWritePost * call s:my_asyncjob_on_save()
  " https://github.com/vim/vim/issues/5571
  autocmd StdinReadPost * set nomodified
augroup END


" --------------------------------------
" dpp.vim
"
let s:dpp_path = $XDG_CONFIG_HOME->expand() .. '/vim/dpp/dpp.vim'
if filereadable(s:dpp_path) && !exists('*dpp#min#load_state')
  execute 'source' s:dpp_path
endif
