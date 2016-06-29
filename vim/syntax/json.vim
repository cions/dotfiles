" Vim syntax file
" Language:     JSON
" Maintainer:   cions <gh.cions@gmail.com>
" Last Change:  2016-06-28

if v:version < 600
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

syntax case     match
syntax match    jsonCommaError  /,\ze\_s*[]}]/ contained
syntax match    jsonKeyError    /\h\w*\ze\_s*:/ contained
syntax region   jsonObject      matchgroup=jsonBracket start=/{/ end=/}/ contains=ALLBUT,jsonEscape transparent
syntax region   jsonArray       matchgroup=jsonBracket start=/\[/ end=/]/ contains=ALLBUT,jsonKeyError,jsonEscape transparent
syntax region   jsonString      start=/"/ skip=/\\./ end=/"/ display oneline contains=jsonEscape,@Spell
syntax region   jsonStringError start=/'/ skip=/\\./ end=/'/ display oneline
syntax match    jsonEscape      /\\\%(["/\\bfnrt]\|u\x\{4}\)/ display contained
syntax match    jsonNumber      /-\=\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=/ display
syntax match    jsonNumberError /-\=0\%(\d\+\|[box]\x*\)/ display
syntax keyword  jsonBoolean     true false
syntax keyword  jsonNull        null

highlight link  jsonBracket     Operator
highlight link  jsonString      String
highlight link  jsonEscape      Special
highlight link  jsonNumber      Number
highlight link  jsonBoolean     Boolean
highlight link  jsonNull        Constant

highlight link  jsonCommaError  Error
highlight link  jsonKeyError    Error
highlight link  jsonStringError Error
highlight link  jsonNumberError Error

let b:current_syntax = 'json'
let &cpo = s:save_cpo
unlet s:save_cpo
