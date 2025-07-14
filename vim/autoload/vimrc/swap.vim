scriptversion 4

function vimrc#swap#setup() abort
  xnoremap <silent> gs :<C-u>call vimrc#swap#region_interactively()<CR>
  nnoremap <silent> sos <Cmd>call vimrc#swap#set_sorter('s')<CR>
  nnoremap <silent> sop <Cmd>call vimrc#swap#set_sorter('s', input('Prefix> '))<CR>
  nnoremap <silent> soi <Cmd>call vimrc#swap#set_sorter('i')<CR>
  nnoremap <silent> soI <Cmd>call vimrc#swap#set_sorter('i', input('Prefix> '))<CR>
  nnoremap <silent> son <Cmd>call vimrc#swap#set_sorter('n')<CR>
  nnoremap <silent> sof <Cmd>call vimrc#swap#set_sorter('f')<CR>

  omap i, <Plug>(swap-textobject-i)
  xmap i, <Plug>(swap-textobject-i)
  omap a, <Plug>(swap-textobject-a)
  xmap a, <Plug>(swap-textobject-a)

  let g:swap#rules = [
        \   {
        \     'mode': 'n',
        \     'body': '[[:alnum:]_-]\+\%(\s\+[[:alnum:]_-]\+\)\+',
        \     'delimiter': ['\s\+'],
        \     'priority': -20,
        \   },
        \   {
        \     'mode': 'n',
        \     'body': '[[:alnum:]_-]\+\%(\s*,\s*[[:alnum:]_-]\+\)\+',
        \     'delimiter': ['\s*,\s*'],
        \     'priority': -10,
        \   },
        \   {
        \     'mode': 'n',
        \     'surrounds': ['{', '}', 1],
        \     'delimiter': ['\s*,\s*'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"'], ['''', '''']],
        \     'immutable': ['\n\s*', '^\s\+', '\\\n\@='],
        \   },
        \   {
        \     'mode': 'n',
        \     'surrounds': ['\[', '\]', 1],
        \     'delimiter': ['\s*,\s*'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"'], ['''', '''']],
        \     'immutable': ['\n\s*', '^\s\+', '\\\n\@='],
        \   },
        \   {
        \     'mode': 'n',
        \     'surrounds': ['(', ')', 1],
        \     'delimiter': ['\s*,\s*'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"'], ['''', '''']],
        \     'immutable': ['\n\s*', '^\s\+', '\\\n\@='],
        \   },
        \   {
        \     'mode': 'n',
        \     'filetype': ['vim'],
        \     'surrounds': ['{', '}', 1],
        \     'delimiter': ['\s*,\s*'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"']],
        \     'literal_quotes': [['''', '''']],
        \     'immutable': ['\n\s*\\\s*'],
        \   },
        \   {
        \     'mode': 'n',
        \     'filetype': ['vim'],
        \     'surrounds': ['\[', '\]', 1],
        \     'delimiter': ['\s*,\s*'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"']],
        \     'literal_quotes': [['''', '''']],
        \     'immutable': ['\n\s*\\\s*'],
        \   },
        \   {
        \     'mode': 'n',
        \     'filetype': ['vim'],
        \     'surrounds': ['(', ')', 1],
        \     'delimiter': ['\s*,\s*'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"']],
        \     'literal_quotes': [['''', '''']],
        \     'immutable': ['\n\s*\\\s*'],
        \   },
        \ ]

  call vimrc#swap#set_sorter('s')
endfunction

function vimrc#swap#region_interactively() abort
  call setpos('.', getpos("'<"))
  if searchpos('\%V,', 'cnW') != [0, 0]
    let rules = [
          \   {
          \     'mode': 'x',
          \     'delimiter': ['\s*,\s*'],
          \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
          \     'quotes': [['"', '"'], ['''', '''']],
          \     'immutable': ['\n\s*', '^\s\+', '\\\n\@='],
          \   },
          \   {
          \     'mode': 'x',
          \     'filetype': ['vim'],
          \     'delimiter': ['\s*,\s*'],
          \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
          \     'quotes': [['"', '"']],
          \     'literal_quotes': [['''', '''']],
          \     'immutable': ['\n\s*\\\s*'],
          \   },
          \ ]
  else
    let rules = [
        \   {
        \     'mode': 'x',
        \     'delimiter': ['\s\+'],
        \     'braket': [['(', ')'], ['[', ']'], ['{', '}']],
        \     'quotes': [['"', '"'], ['''', '''']],
        \     'immutable': ['\n\s*', '\\\n\@='],
        \   },
        \ ]
  endif
  call swap#region_interactively("'<", "'>", visualmode(), rules)
endfunction

function vimrc#swap#set_sorter(mode, ...) abort
  let prefix = get(a:000, 0, v:null)
  if a:mode ==# 's' && prefix isnot# v:null
    let g:swap#mode#sortfunc = [{x, y -> s:cmp(s:strip_prefix(x.str, prefix), s:strip_prefix(y.str, prefix))}]
    let g:swap#mode#SORTFUNC = [{x, y -> -s:cmp(s:strip_prefix(x.str, prefix), s:strip_prefix(y.str, prefix))}]
  elseif a:mode ==# 's'
    let g:swap#mode#sortfunc = [{x, y -> s:cmp(x.str, y.str)}]
    let g:swap#mode#SORTFUNC = [{x, y -> -s:cmp(x.str, y.str)}]
  elseif a:mode ==# 'i' && prefix isnot# v:null
    let g:swap#mode#sortfunc = [{x, y -> s:icmp(s:strip_prefix(x.str, prefix), s:strip_prefix(y.str, prefix))}]
    let g:swap#mode#SORTFUNC = [{x, y -> -s:icmp(s:strip_prefix(x.str, prefix), s:strip_prefix(y.str, prefix))}]
  elseif a:mode ==# 'i'
    let g:swap#mode#sortfunc = [{x, y -> s:icmp(x.str, y.str)}]
    let g:swap#mode#SORTFUNC = [{x, y -> -s:icmp(x.str, y.str)}]
  elseif a:mode ==# 'n'
    let g:swap#mode#sortfunc = [{x, y -> s:cmpnum(x.str, y.str)}]
    let g:swap#mode#SORTFUNC = [{x, y -> -s:cmpnum(x.str, y.str)}]
  elseif a:mode ==# 'f'
    let g:swap#mode#sortfunc = [{x, y -> s:cmp(str2float(x.str), str2float(y.str))}]
    let g:swap#mode#SORTFUNC = [{x, y -> -s:cmp(str2float(x.str), str2float(y.str))}]
  endif
endfunction

function s:strip_prefix(str, prefix) abort
  let m = matchstrpos(a:str, '^\%(' .. a:prefix .. '\)')
  return m[2] != -1 ? strpart(a:str, m[2]) : a:str
endfunction

function s:cmpnum(x, y) abort
  let m1 = matchstrpos(a:x, '-\=\%(0x\x\+\|\d\+\)')
  if m1[1] ==# -1
    let [h1, b1, t1] = [a:x, '', '']
  else
    let [h1, b1, t1] = [strpart(a:x, 0, m1[1]), m1[0], strpart(a:x, m1[2])]
  endif
  let b1 = b1 =~# '0x' ? str2nr(b1, 16) : str2nr(b1, 10)

  let m2 = matchstrpos(a:y, '-\=\%(0x\x\+\|\d\+\)')
  if m2[1] ==# -1
    let [h2, b2, t2] = [a:y, '', '']
  else
    let [h2, b2, t2] = [strpart(a:y, 0, m2[1]), m2[0], strpart(a:y, m2[2])]
  endif
  let b2 = b2 =~# '0x' ? str2nr(b2, 16) : str2nr(b2, 10)

  return s:or(s:cmp(h1, h2), s:cmp(b1, b2), s:cmp(t1, t2))
endfunction

function s:cmp(x, y) abort
  if a:x ==# a:y
    return 0
  elseif a:x <# a:y
    return -1
  else
    return 1
  endif
endfunction

function s:icmp(x, y) abort
  if a:x ==? a:y
    return 0
  elseif a:x <? a:y
    return -1
  else
    return 1
  endif
endfunction

function s:or(...) abort
  for arg in a:000
    if arg !=# 0
      return arg
    endif
  endfor
  return 0
endfunction
