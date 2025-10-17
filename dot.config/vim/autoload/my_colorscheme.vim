" Colorscheme management with random selection

" Light colorschemes
let s:colorschemes_light = [
      \ 'delek',
      \ 'morning',
      \ 'peachpuff',
      \ 'shine',
      \ 'zellner',
      \ ]

" Dark colorschemes
let s:colorschemes_dark = [
      \ 'blue',
      \ 'darkblue',
      \ 'desert',
      \ 'elflord',
      \ 'evening',
      \ 'habamax',
      \ 'industry',
      \ 'koehler',
      \ 'murphy',
      \ 'pablo',
      \ 'ron',
      \ 'slate',
      \ 'sorbet',
      \ 'torte',
      \ 'unokai',
      \ 'zaibatsu',
      \ ]

" Both light and dark colorschemes
let s:colorschemes_both = [
      \ 'lunaperche',
      \ 'quiet',
      \ 'retrobox',
      \ 'wildcharm',
      \ ]

" Get theme type from cache
function! s:get_theme_type() abort
  let l:cache_file = $XDG_CACHE_HOME->expand() .. '/terminal-theme'
  if filereadable(l:cache_file)
    let l:theme_type = trim(readfile(l:cache_file)[0])
    if l:theme_type ==# 'light'
      return 'light'
    endif
  endif
  return 'dark'
endfunction

" Select random colorscheme based on theme type
function! s:select_random_colorscheme(theme_type) abort
  if a:theme_type ==# 'light'
    let l:schemes = s:colorschemes_light + s:colorschemes_both
  else
    let l:schemes = s:colorschemes_dark + s:colorschemes_both
  endif

  let l:index = str2nr(system('echo $RANDOM')) % len(l:schemes)
  return l:schemes[l:index]
endfunction

" Setup colorscheme based on Alacritty theme
function! my_colorscheme#setup() abort
  " Get theme type
  let l:theme_type = s:get_theme_type()

  " Select and apply random colorscheme
  let l:colorscheme = s:select_random_colorscheme(l:theme_type)

  try
    execute 'colorscheme' l:colorscheme
  catch
    " Fallback to default
    colorscheme retrobox
  endtry
endfunction
