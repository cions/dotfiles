if has('win32')
  let g:lightline = {
        \   'colorscheme': 'wombat',
        \   'separator': { 'left': ">", 'right': "<" },
        \   'subseparator': { 'left': " ", 'right': " " },
        \ }
else
  let g:lightline = {
        \   'colorscheme': 'wombat',
        \   'separator': { 'left': "\uE0B0", 'right': "\uE0B2" },
        \   'subseparator': { 'left': "\uE0B1", 'right': "\uE0B3" },
        \ }
endif
