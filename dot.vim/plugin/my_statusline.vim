" set statusline=%{'-'->repeat(&columns)}
set statusline=%!my_statusline#statusline()
set tabline=%!my_statusline#tabline()
