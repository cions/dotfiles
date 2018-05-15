" Vim indent file
" Language:    JSON
" Maintainer:  cions <gh.cions@gmail.com>
" Last Change: 2018-05-15

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal indentexpr=GetJSONIndent(v:lnum)
setlocal indentkeys=0{,0[,},],!^F,o,O
setlocal nosmartindent

let b:undo_indent = 'setlocal indentexpr< indentkeys< smartindent<'

function! s:count_brackets(lnum, which)
  let open = 0
  let close = 0
  let line = getline(a:lnum)
  let i = match(line, '[][{}"]')
  while i != -1
    if line[i] ==# '"'
      let i = match(line, '\%(\%(\%([^\\"]\+\)\@>\|\\.\)*\)\@>"\zs', i + 1)
      continue
    elseif line[i] ==# '{' || line[i] ==# '['
      let open += 1
    elseif line[i] ==# '}' || line[i] ==# ']'
      let close += 1
    endif
    let i = match(line, '[][{}"]', i + 1)
  endwhile
  if a:which ==# 'open'
    return max([open - close, 0])
  else
    return max([close - open, 0])
  endif
endfunction

function! GetJSONIndent(lnum)
  let pnum = prevnonblank(a:lnum - 1)
  if pnum > 0
    let indent = indent(pnum)
    let indent += s:count_brackets(pnum, 'open') * &l:shiftwidth
    let indent -= s:count_brackets(a:lnum, 'close') * &l:shiftwidth
    return indent
  else
    return 0
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
