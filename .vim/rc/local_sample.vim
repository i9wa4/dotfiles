scriptencoding utf-8

let g:my_bookmark_path = expand('~/work/bookmark.md')
let g:my_gtd_path = expand('~/work/gtd.md')

if exists('$VENV_MYENV') && exists('$PY_VER_MINOR')
  let g:python3_host_prog = expand($VENV_MYENV . '/bin/python' . $PY_VER_MINOR)
  call my_vimrc#add_path([expand($VENV_MYENV . '/bin')])
endif
