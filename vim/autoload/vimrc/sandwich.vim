scriptversion 4

function vimrc#sandwich#setup() abort
  xmap ib <Plug>(textobj-sandwich-auto-i)
  omap ib <Plug>(textobj-sandwich-auto-i)
  xmap ab <Plug>(textobj-sandwich-auto-a)
  omap ab <Plug>(textobj-sandwich-auto-a)
  xmap iq <Plug>(textobj-sandwich-query-i)
  omap iq <Plug>(textobj-sandwich-query-i)
  xmap aq <Plug>(textobj-sandwich-query-a)
  omap aq <Plug>(textobj-sandwich-query-a)
  xmap is <Plug>(textobj-sandwich-literal-query-i)
  omap is <Plug>(textobj-sandwich-literal-query-i)
  xmap as <Plug>(textobj-sandwich-literal-query-a)
  omap as <Plug>(textobj-sandwich-literal-query-a)

  for x in ['f', 'F', 'i', 'I', 't', 'T', '{', '}', '[', ']', '(', ')', '<', '>',
        \   '"', "'", '`', '3"', "3'", '3`', '<Space>', '<CR>']
    execute "xmap" "i"..x "<Plug>(textobj-sandwich-query-i)"..x
    execute "omap" "i"..x "<Plug>(textobj-sandwich-query-i)"..x
    execute "xmap" "a"..x "<Plug>(textobj-sandwich-query-a)"..x
    execute "omap" "a"..x "<Plug>(textobj-sandwich-query-a)"..x
  endfor

  let g:textobj_sandwich_no_default_key_mappings = 1
  let g:sandwich_no_tex_ftplugin = 1
  let g:sandwich_no_vim_ftplugin = 1

  let g:sandwich#recipes = []

  let g:sandwich#recipes += [
        \   #{ input: ['('], buns: ['( ', ' )'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: ['['], buns: ['[ ', ' ]'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: ['{'], buns: ['{ ', ' }'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: [')'], buns: ['(', ')'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: [']'], buns: ['[', ']'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: ['}'], buns: ['{', '}'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: ['(', ')'], buns: ['(', ')'], kind: ['add', 'replace'], action: ['add'],
        \      motionwise: ['line'], linewise: 1, nesting: 1 },
        \   #{ input: ['[', ']'], buns: ['[', ']'], kind: ['add', 'replace'], action: ['add'],
        \      motionwise: ['line'], linewise: 1, nesting: 1 },
        \   #{ input: ['{', '}'], buns: ['{', '}'], kind: ['add', 'replace'], action: ['add'],
        \      motionwise: ['line'], linewise: 1, nesting: 1 },
        \   #{ input: ['('], buns: ['(\s*', '\s*)'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      regex: 1, match_syntax: 1, linewise: 1, skip_break: 1, nesting: 1 },
        \   #{ input: ['['], buns: ['\[\s*', '\s*\]'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      regex: 1, match_syntax: 1, linewise: 1, skip_break: 1, nesting: 1 },
        \   #{ input: ['{'], buns: ['{\s*', '\s*}'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      regex: 1, match_syntax: 1, linewise: 1, skip_break: 1, nesting: 1 },
        \   #{ input: [')'], buns: ['(', ')'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      match_syntax: 1, linewise: 1, nesting: 1 },
        \   #{ input: [']'], buns: ['[', ']'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      match_syntax: 1, linewise: 1, nesting: 1 },
        \   #{ input: ['}'], buns: ['{', '}'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      match_syntax: 1, linewise: 1, nesting: 1 },
        \ ]

  let g:sandwich#recipes += [
        \   #{ input: ['<'], buns: ['< ', ' >'], kind: ['add', 'replace'], action: ['add'], nesting: 1 },
        \   #{ input: ['<'], buns: ['<\s*', '\s*>'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      regex: 1, match_syntax: 1, nesting: 1 },
        \   #{ input: ['>'], buns: ['<', '>'], match_syntax: 1, nesting: 1 },
        \ ]

  let g:sandwich#recipes += [
        \   #{ input: ['"'], buns: ['"', '"'], quoteescape: 1, expand_range: 0, nesting: 0 },
        \   #{ input: ["'"], buns: ["'", "'"], quoteescape: 1, expand_range: 0, nesting: 0 },
        \   #{ input: ['`'], buns: ['`', '`'], quoteescape: 1, expand_range: 0, nesting: 0 },
        \   #{ input: ['3"'], buns: ['"""', '"""'], nesting: 0, linewise: 1 },
        \   #{ input: ["3'"], buns: ["'''", "'''"], nesting: 0, linewise: 1 },
        \   #{ input: ['3`'], buns: ['```', '```'], nesting: 0, linewise: 1 },
        \ ]

  let g:sandwich#recipes += [
        \   #{ input: [' '], buns: ['\s\+', '\s\+'], regex: 1, kind: ['delete', 'replace', 'query'] },
        \   #{ input: ["\<CR>"], buns: ['', ''], kind: ['add', 'replace'], action: ['add'], motionwise: ['line'], linewise: 1 },
        \   #{ input: ["\<CR>"], buns: ['^\s*$', '^\s*$'], kind: ['query'], regex: 1 },
        \ ]

  let g:sandwich#recipes += [
        \   #{ input: ['t', 'T'], buns: 'sandwich#magicchar#t#tag()', kind: ['add'], action: ['add'], listexpr: 1 },
        \   #{ input: ['t'], buns: 'sandwich#magicchar#t#tagname()', kind: ['replace'], action: ['add'], listexpr: 1 },
        \   #{ input: ['T'], buns: 'sandwich#magicchar#t#tag()', kind: ['replace'], action: ['add'], listexpr: 1 },
        \   #{ input: ['t', 'T'], external: ["\<Plug>(textobj-sandwich-tag-i)", "\<Plug>(textobj-sandwich-tag-a)"],
        \      kind: ['delete', 'textobj'], action: ['delete'], noremap: 0, linewise: 1 },
        \   #{ input: ['t'], external: ["\<Plug>(textobj-sandwich-tagname-i)", "\<Plug>(textobj-sandwich-tagname-a)"],
        \      kind: ['replace', 'query'], action: ['delete'], expr_filter: ['operator#sandwich#kind() ==# "replace"'], noremap: 0 },
        \   #{ input: ['T'], external: ["\<Plug>(textobj-sandwich-tag-i)", "\<Plug>(textobj-sandwich-tag-a)"],
        \      kind: ['replace', 'query'], action: ['delete'], expr_filter: ['operator#sandwich#kind() ==# "replace"'], noremap: 0 },
        \ ]

  let g:sandwich#recipes += [
        \   #{ input: ['f'], buns: ['sandwich#magicchar#f#fname()', '")"'], kind: ['add', 'replace'], action: ['add'], expr: 1 },
        \   #{ input: ['f'], external: ["\<Plug>(textobj-sandwich-function-ip)", "\<Plug>(textobj-sandwich-function-i)"],
        \      kind: ['delete', 'replace', 'query'], noremap: 0 },
        \   #{ input: ['F'], external: ["\<Plug>(textobj-sandwich-function-ap)", "\<Plug>(textobj-sandwich-function-a)"],
        \      kind: ['delete', 'replace', 'query'], noremap: 0 },
        \ ]

  let g:sandwich#recipes += [
        \   #{ input: ['i'], buns: 'sandwich#magicchar#i#input("operator")', kind: ['add', 'replace'], action: ['add'], listexpr: 1 },
        \   #{ input: ['i'], buns: 'sandwich#magicchar#i#input("textobj", 1)', kind: ['delete', 'replace', 'query'], listexpr: 1 },
        \   #{ input: ['I'], buns: 'sandwich#magicchar#i#lastinput("operator", 1)', kind: ['add', 'replace'], action: ['add'], listexpr: 1 },
        \   #{ input: ['I'], buns: 'sandwich#magicchar#i#lastinput("textobj")', kind: ['delete', 'replace', 'query'], listexpr: 1 },
        \ ]

  augroup vimrc-sandwich
    autocmd!
    autocmd FileType plaintex,tex call vimrc#sandwich#setup_tex()
    autocmd FileType python call vimrc#sandwich#setup_python()
    autocmd FileType vim call vimrc#sandwich#setup_vim()
  augroup END
endfunction

function vimrc#sandwich#setup_tex() abort
  for x in ['$', '<Bar>', '<Bslash>', 'c', 'e', 'm']
    execute "xmap" "<buffer>" "i"..x "<Plug>(textobj-sandwich-query-i)"..x
    execute "omap" "<buffer>" "i"..x "<Plug>(textobj-sandwich-query-i)"..x
    execute "xmap" "<buffer>" "a"..x "<Plug>(textobj-sandwich-query-a)"..x
    execute "omap" "<buffer>" "a"..x "<Plug>(textobj-sandwich-query-a)"..x
  endfor

  call sandwich#util#addlocal([
        \   #{ input: ['$'], buns: ['$', '$'], nesting: 0 },
        \   #{ input: ['|'], buns: ['|', '|'], nesting: 0 },
        \   #{ input: ['\(', '\)'], buns: ['\(', '\)'], nesting: 1, indentkeys-: '(,),0(,0)' },
        \   #{ input: ['\[', '\]'], buns: ['\[', '\]'], nesting: 1, indentkeys-: '[,],0[,0]' },
        \   #{ input: ['\{', '\}'], buns: ['\{', '\}'], nesting: 1, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['\V'], buns: ['\lVert ', '\rVert '], nesting: 1 },
        \   #{ input: ['\f'], buns: ['\lfloor ', '\rfloor '], nesting: 1 },
        \   #{ input: ['\c'], buns: ['\lceil ', '\rceil '], nesting: 1 },
        \   #{ input: ['a(', 'a)'], buns: ['\left(', '\right)'], action: ['add'], nesting: 1, indentkeys-: '(,),0(,0)' },
        \   #{ input: ['a[', 'a]'], buns: ['\left[', '\right]'], action: ['add'], nesting: 1, indentkeys-: '[,],0[,0]' },
        \   #{ input: ['a{', 'a}'], buns: ['\left\{', '\right\}'], action: ['add'], nesting: 1, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['a<', 'a>'], buns: ['\left\langle ', '\right\rangle '], action: ['add'], nesting: 1 },
        \   #{ input: ['a|'], buns: ['\left\lvert ', '\right\rvert '], action: ['add'], nesting: 1 },
        \   #{ input: ['aV'], buns: ['\left\lVert ', '\right\rVert '], action: ['add'], nesting: 1 },
        \   #{ input: ['af'], buns: ['\left\lfloor ', '\right\rfloor '], action: ['add'], nesting: 1 },
        \   #{ input: ['ac'], buns: ['\left\lceil ', '\right\rceil '], action: ['add'], nesting: 1 },
        \   #{ input: ['b(', 'b)'], buns: ['\bigl(', '\bigr)'], action: ['add'], nesting: 1, indentkeys-: '(,),0(,0)' },
        \   #{ input: ['b[', 'b]'], buns: ['\bigl[', '\bigr]'], action: ['add'], nesting: 1, indentkeys-: '[,],0[,0]' },
        \   #{ input: ['b{', 'b}'], buns: ['\bigl\{', '\bigr\}'], action: ['add'], nesting: 1, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['b<', 'b>'], buns: ['\bigl\langle ', '\bigr\rangle '], action: ['add'], nesting: 1 },
        \   #{ input: ['b|'], buns: ['\bigl\lvert ', '\bigr\rvert '], action: ['add'], nesting: 1 },
        \   #{ input: ['bV'], buns: ['\bigl\lVert ', '\bigr\rVert '], action: ['add'], nesting: 1 },
        \   #{ input: ['bf'], buns: ['\bigl\lfloor ', '\bigr\rfloor '], action: ['add'], nesting: 1 },
        \   #{ input: ['bc'], buns: ['\bigl\lceil ', '\bigr\rceil '], action: ['add'], nesting: 1 },
        \   #{ input: ['B(', 'B)'], buns: ['\Bigl(', '\Bigr)'], action: ['add'], nesting: 1, indentkeys-: '(,),0(,0)' },
        \   #{ input: ['B[', 'B]'], buns: ['\Bigl[', '\Bigr]'], action: ['add'], nesting: 1, indentkeys-: '[,],0[,0]' },
        \   #{ input: ['B{', 'B}'], buns: ['\Bigl\{', '\Bigr\}'], action: ['add'], nesting: 1, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['B<', 'B>'], buns: ['\Bigl\langle ', '\Bigr\rangle '], action: ['add'], nesting: 1 },
        \   #{ input: ['B|'], buns: ['\Bigl\lvert ', '\Bigr\rvert '], action: ['add'], nesting: 1 },
        \   #{ input: ['BV'], buns: ['\Bigl\lVert ', '\Bigr\rVert '], action: ['add'], nesting: 1 },
        \   #{ input: ['Bf'], buns: ['\Bigl\lfloor ', '\Bigr\rfloor '], action: ['add'], nesting: 1 },
        \   #{ input: ['Bc'], buns: ['\Bigl\lceil ', '\Bigr\rceil '], action: ['add'], nesting: 1 },
        \ ])

  call sandwich#util#addlocal([
        \   #{ input: ['c'], buns: 'sandwich#filetype#tex#CmdInput()', kind: ['add', 'replace'], action: ['add'],
        \      listexpr: 1, nesting: 1, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['e'], buns: 'sandwich#filetype#tex#EnvInput()', kind: ['add', 'replace'], action: ['add'],
        \      listexpr: 1, linewise: 1, nesting: 1, autoindent: 0, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['c'], buns: ['\\\a\+\*\={', '}'], kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      regex: 1, nesting: 1, indentkeys-: '{,},0{,0}' },
        \   #{ input: ['e'], buns: ['\\begin{[^}]\+}\%({[^}]*}\|\[[^]]*\]\)\=', '\\end{[^}]\+}'],
        \      kind: ['delete', 'replace', 'textobj'], action: ['delete'],
        \      regex: 1, linewise: 1, nesting: 1, autoindent: 0, indentkeys-: '{,},0{,0}' },
        \   #{ external: ["\<Plug>(textobj-sandwich-filetype-tex-marks-i)", "\<Plug>(textobj-sandwich-filetype-tex-marks-a)"],
        \      input: ['m'], kind: ['delete', 'replace', 'textobj'], noremap: 0, autoindent: 0, indentkeys: '{,},0{,0}' },
        \ ])

  let b:sandwich_tex_marks_recipes = []

  let b:sandwich_tex_marks_recipes += [
        \   #{ buns: ['\C\\left\%([[(|.]\|\\{\|\\langle\|\\lvert\|\\lVert\|\\lfloor\|\\lceil\)',
        \             '\C\\right\%([])|.]\|\\}\|\\rangle\|\\rvert\|\\rVert\|\\rfloor\|\\rceil\)'],
        \      regex: 1, nesting: 1 },
        \   #{ buns: ['\C\\bigl\%([[(|.]\|\\{\|\\langle\|\\lvert\|\\lVert\|\\lfloor\|\\lceil\)',
        \             '\C\\bigr\%([])|.]\|\\}\|\\rangle\|\\rvert\|\\rVert\|\\rfloor\|\\rceil\)'],
        \      regex: 1, nesting: 1 },
        \   #{ buns: ['\C\\Bigl\%([[(|.]\|\\{\|\\langle\|\\lvert\|\\lVert\|\\lfloor\|\\lceil\)',
        \             '\C\\Bigr\%([])|.]\|\\}\|\\rangle\|\\rvert\|\\rVert\|\\rfloor\|\\rceil\)'],
        \      regex: 1, nesting: 1 },
        \   #{ buns: ['\C\\Biggl\%([[(|.]\|\\{\|\\langle\|\\lvert\|\\lVert\|\\lfloor\|\\lceil\)',
        \             '\C\\Biggr\%([])|.]\|\\}\|\\rangle\|\\rvert\|\\rVert\|\\rfloor\|\\rceil\)'],
        \      regex: 1, nesting: 1 },
        \ ]

  xnoremap <silent><expr> <Plug>(textobj-sandwich-filetype-tex-marks-i)
        \ textobj#sandwich#auto('x', 'i', {'synchro': 0}, b:sandwich_tex_marks_recipes)
  onoremap <silent><expr> <Plug>(textobj-sandwich-filetype-tex-marks-i)
        \ textobj#sandwich#auto('o', 'i', {'synchro': 0}, b:sandwich_tex_marks_recipes)
  xnoremap <silent><expr> <Plug>(textobj-sandwich-filetype-tex-marks-a)
        \ textobj#sandwich#auto('x', 'a', {'synchro': 0}, b:sandwich_tex_marks_recipes)
  onoremap <silent><expr> <Plug>(textobj-sandwich-filetype-tex-marks-a)
        \ textobj#sandwich#auto('o', 'a', {'synchro': 0}, b:sandwich_tex_marks_recipes)
endfunction

function vimrc#sandwich#setup_python() abort
  let prefixes = [
        \   'r', 'u', 'R', 'U', 'f', 'F', 'fr', 'Fr',
        \   'fR', 'FR', 'rf', 'rF', 'Rf', 'RF', 'b', 'B',
        \   'br', 'Br', 'bR', 'BR', 'rb', 'rB', 'Rb', 'RB',
        \ ]
  for prefix in prefixes
    call sandwich#util#addlocal([
          \   #{ input: [prefix..'"'], buns: [prefix..'"', '"'], quoteescape: 1, expand_range: 0, nesting: 0 },
          \   #{ input: [prefix.."'"], buns: [prefix.."'", "'"], quoteescape: 1, expand_range: 0, nesting: 0 },
          \   #{ input: [prefix..'3"'], buns: [prefix..'"""', '"""'], nesting: 0, linewise: 1 },
          \   #{ input: [prefix.."3'"], buns: [prefix.."'''", "'''"], nesting: 0, linewise: 1 },
          \ ])
  endfor
endfunction

function vimrc#sandwich#setup_vim() abort
  let b:sandwich_magicchar_f_patterns = [
    \   {
    \     'header' : '\C\<\%(\h\k*\|[sa]:\h\k*\|g:[A-Z]\k*\|\%(g:\)\=\h\k*\%(#\h\k*\)\+\)',
    \     'bra'    : '(',
    \     'ket'    : ')',
    \     'footer' : '',
    \   },
    \ ]

  call sandwich#util#addlocal([
        \   #{ input: ["'"], buns: ["'", "'"], match_syntax: 2, expand_range: 0, nesting: 0, linewise: 0,
        \      skip_expr: ["synIDattr(synID(line('.'), col('.'), 0), 'name') ==# 'vimQuoteEscape'"] },
        \ ])
endfunction
