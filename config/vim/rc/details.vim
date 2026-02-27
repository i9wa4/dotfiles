" --------------------------------------
" Variable
"
let g:markdown_recommended_style = 0
let g:netrw_banner = 0
let g:netrw_dirhistmax = 0
let g:netrw_hide = 0
let g:netrw_liststyle = 0
let g:vim_indent = #{
\   line_continuation: 0
\ }

let g:auto_reload = timer_start(
\   1000,
\   {-> execute('silent! checktime')},
\   {'repeat': -1}
\ )


" --------------------------------------
" Option
"
" Edit
set completeopt=menuone,noinsert,noselect
set fileencodings=utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set hidden
set nofoldenable autoindent
set nrformats=unsigned
set virtualedit=block

" Search
if executable('rg')
  let &grepprg = 'rg --vimgrep --no-heading'
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
set number
set signcolumn=number

" Window
set noequalalways
set splitbelow
set splitright
set wildmenu wildoptions=pum,tagfile wildchar=<Tab>

" CommandLine
set cmdheight=1
set showcmd

" StatusLine
set laststatus=2

" TabLine
set showtabline=2

" Highlight
set cursorline
" set diffopt=internal,filler,closeoff,indent-heuristic,algorithm:histogram

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

" https://blog.atusy.net/2025/08/08/map-minus-to-blackhole-register/
nnoremap - "_
xnoremap - "_

" Toggle Quote
nnoremap gqq :call <SID>toggle_quote()<CR>
vnoremap gqq :call <SID>toggle_quote()<CR>

function! s:toggle_quote() range abort
  let l:all_quoted = v:true
  for l:lnum in range(a:firstline, a:lastline)
    if getline(l:lnum) !~ '^>'
      let l:all_quoted = v:false
      break
    endif
  endfor

  for l:lnum in range(a:firstline, a:lastline)
    let l:line = getline(l:lnum)
    if l:all_quoted
      call setline(l:lnum, substitute(l:line, '^>\s\?', '', ''))
    else
      call setline(l:lnum, '> ' .. l:line)
    endif
  endfor
endfunction

" Insert Mode
" i_CTRL-T Insert one indent
" i_CTRL-D Delete one indent
inoremap ,now <C-r>=strftime('%Y-%m-%d %X +0900')<CR>
inoremap ,today <C-r>=strftime('%Y-%m-%d')<CR>

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
nnoremap <Plug>(my-Edit)r  <Cmd>%s/\r$//e<CR>
nnoremap <Plug>(my-Edit)s  <Cmd>%s/\s\+$//e<CR>
nnoremap <Plug>(my-Edit)n  <Cmd>%s/\%ua0//e<CR>
nnoremap <Plug>(my-Edit)qa <Cmd>%s/\([^,]*\)/"\1"/g<CR>
nnoremap <Plug>(my-Edit)qr <Cmd>%s/"//g<CR>

" Filer
" nnoremap <Plug>(my-Filer)cd <Cmd>execute 'cd' fnamemodify(finddir('.git', escape(expand(getcwd()), ' ') .. ';', 1), ':h')<CR>
nnoremap <Plug>(my-Filer) <Nop>
nmap <Space>f <Plug>(my-Filer)
nnoremap <Plug>(my-Filer)aa <Cmd>execute 'edit' g:my_aa_path<CR>
nnoremap <Plug>(my-Filer)c  <Cmd>execute '15Lexplore'<CR>
nnoremap <Plug>(my-Filer)i0 <Cmd>execute 'edit' g:my_i0_path<CR>
nnoremap <Plug>(my-Filer)i1 <Cmd>execute 'edit' g:my_i1_path<CR>
nnoremap <Plug>(my-Filer)i2 <Cmd>execute 'edit' g:my_i2_path<CR>
nnoremap <Plug>(my-Filer)o  <Cmd>execute '15Lexplore' '%:p:h'->expand()<CR>
nnoremap <Plug>(my-Filer)t  <Cmd>execute 'edit' g:my_tp_path<CR>
nnoremap <Plug>(my-Filer)v  <Cmd>execute 'edit' $MYVIMRC<CR>

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

command! S call s:set_register()
function! s:set_register() abort
  if empty(&buftype)
    call setreg('a', '%'->expand()->fnamemodify(':p'))
    call setreg('b', '%'->expand()->fnamemodify(':p:~'))
    call setreg('c', '%'->expand()->fnamemodify(':p:~:t'))
  endif
endfunction

command! CreateLocalVimrc
\   call system('echo "\" ~/ghq/github.com/i9wa4/dotfiles/config/vim/rc/local.default.vim" > ./local.vim')
\|  call system('echo "let g:mnh_header_level_shift = 1" >> ./local.vim')


" --------------------------------------
" Command
"
augroup MyAutocmd
  autocmd!

  autocmd BufEnter,CursorHold * checktime
  autocmd BufReadPost * call utils#restore_cursor()
  autocmd VimEnter,BufNewFile,BufReadPost,BufEnter *
  \ call utils#source_local_vimrc('<afile>:p'->expand())

  autocmd FileType * call utils#filetype()
  autocmd BufNewFile,BufReadPost *.tf,*.tftpl
  \ setfiletype terraform
  autocmd BufNewFile,BufReadPost *.zshenv,*.zshrc
  \ setfiletype zsh

  autocmd VimEnter,BufEnter,WinEnter,FileType *
  \ call utils#highlight()
augroup END


" --------------------------------------
" dpp.vim
"
let s:dpp_path = $XDG_CONFIG_HOME->expand() .. '/vim/dpp/dpp.vim'
if filereadable(s:dpp_path) && !exists('*dpp#min#load_state')
  execute 'source' s:dpp_path
endif
