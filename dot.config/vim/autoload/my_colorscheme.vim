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

" Get theme type from Alacritty theme.toml
function! s:get_theme_type() abort
  let l:theme_file = expand('~/.config/alacritty/theme.toml')
  if !filereadable(l:theme_file)
    return 'dark'
  endif

  let l:type_line = system('grep "^# TYPE:" ' .. l:theme_file .. ' | cut -d: -f2 | tr -d " \n"')
  if l:type_line ==# 'light'
    return 'light'
  else
    return 'dark'
  endif
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

  " Set background
  if l:theme_type ==# 'light'
    set background=light
  else
    set background=dark
  endif

  " Select and apply random colorscheme
  let l:colorscheme = s:select_random_colorscheme(l:theme_type)

  try
    execute 'colorscheme' l:colorscheme
  catch
    " Fallback to default
    colorscheme retrobox
  endtry
endfunction
