scriptencoding utf-8

let g:my_bookmark_path = ''

if exists('$VENV_MYENV') && exists('$PY_VER_MAJOR')
  let g:python3_host_prog = expand($VENV_MYENV . '/bin/python' . $PY_VER_MAJOR)
  call vimrc#add_path([expand($VENV_MYENV . '/bin')])
endif
