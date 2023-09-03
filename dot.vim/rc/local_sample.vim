scriptencoding utf-8

let g:my_bookmark_path = expand('~/work/bookmark.md')
let g:my_gtd_path = expand('~/work/gtd.md')
let g:my_skk_path = expand('~/work/skk.md')
let g:local_vim_setting_name = fnamemodify(expand('<sfile>'), ":h:t")

if !empty($PY_VENV_MYENV) && !empty($PY_VER_MINOR)
  let g:python3_host_prog = expand($PY_VENV_MYENV . '/bin/python' . $PY_VER_MINOR)
  call my_vimrc#add_path([expand($PY_VENV_MYENV . '/bin')])
endif
