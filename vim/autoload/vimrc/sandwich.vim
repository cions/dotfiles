function vimrc#sandwich#on_source() abort
  augroup vimrc-sandwich
    autocmd!
    autocmd FileType python call vimrc#sandwich#on_ft_python()
  augroup END

  xmap if <Plug>(textobj-sandwich-literal-query-i)
  xmap af <Plug>(textobj-sandwich-literal-query-a)
  omap if <Plug>(textobj-sandwich-literal-query-i)
  omap af <Plug>(textobj-sandwich-literal-query-a)
endfunction

function vimrc#sandwich#on_post_source() abort
  let g:sandwich#recipes = copy(g:sandwich#default_recipes)
  let g:sandwich#recipes += [
        \   {'buns': ['"""', '"""'], 'nesting': 0, 'filetype': ['python', 'toml', 'swift'], 'input': ['m"']},
        \   {'buns': ["'''", "'''"], 'nesting': 0, 'filetype': ['python', 'toml', 'swift'], 'input': ['m''']},
        \ ]
endfunction

function vimrc#sandwich#on_ft_python() abort
  let l:prefixes = [
        \   'r', 'u', 'R', 'U', 'f', 'F', 'fr', 'Fr',
        \   'fR', 'FR', 'rf', 'rF', 'Rf', 'RF', 'b', 'B',
        \   'br', 'Br', 'bR', 'BR', 'rb', 'rB', 'Rb', 'RB',
        \ ]
  for l:prefix in l:prefixes
    call sandwich#util#addlocal([
          \   {'buns': [l:prefix..'"', '"'], 'nesting': 0, 'input': [l:prefix..'"']},
          \   {'buns': [l:prefix.."'", "'"], 'nesting': 0, 'input': [l:prefix.."'"]},
          \   {'buns': [l:prefix..'"""', '"""'], 'nesting': 0, 'input': [l:prefix.."'"]},
          \ ])
  endfor
endfunction
