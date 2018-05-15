" Vim syntax file
" Language:    JSON
" Maintainer:  cions <gh.cions@gmail.com>
" Last Change: 2018-05-15

if exists('b:current_syntax')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('b:vim_json_warnings')
  let b:vim_json_warnings = get(g:, 'vim_json_warnings', 1)
endif

syn case match

syn match jsonColon     ":" contained
                      \ nextgroup=@jsonValue skipwhite skipempty
syn match jsonComma     "," contained display
syn cluster jsonCommas  add=jsonComma

if b:vim_json_warnings
  syn match jsonCommaError            "," contained
  syn match jsonNoQuoteError          "\h\w*" display
  syn match jsonNumberError           "[-+]\=\%(0[box]\x*\|[[:digit:].]\+\)"
  syn region jsonStringError          start="'" skip="\\." end="'" display oneline
  syn match jsonCommentError          "#.*\|//.*"
  syn region jsonCommentError         start="/\*" end="\*/"
  syn cluster jsonErrors              add=jsonCommaError,jsonNoQuoteError,jsonNumberError,jsonStringError,jsonCommentError

  syn match jsonTrailingCommaError    ",\%(\_s*[]}]\)\@=" contained
  syn region jsonMissingCommaError    matchgroup=jsonMissingCommaError start="{" end="}"
                                    \ contains=jsonMissingCommaError contained
  syn region jsonMissingCommaError    matchgroup=jsonMissingCommaError start="\[" end="]"
                                    \ contains=jsonMissingCommaError contained
  syn region jsonMissingCommaError    start='"' skip="\\." end='"'
                                    \ contained display oneline
  syn match jsonMissingCommaError     "-\=\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\ze\%(\s*[^]},]\@!\)"
                                    \ contained display
  syn keyword jsonMissingCommaError   contained true false null
  syn cluster jsonCommas              add=jsonTrailingCommaError,jsonMissingCommaError
endif

syn region jsonObject     matchgroup=jsonBracket start="{" end="}"
                        \ contains=jsonKey,@jsonErrors transparent
                        \ nextgroup=@jsonCommas skipwhite skipempty
syn region jsonArray      matchgroup=jsonBracket start="\[" end="]"
                        \ contains=@jsonValue,@jsonErrors transparent
                        \ nextgroup=@jsonCommas skipwhite skipempty
syn region jsonString     start='"' skip="\\." end='"' oneline
                        \ contains=jsonEscape,@Spell
                        \ nextgroup=@jsonCommas skipwhite skipempty
syn region jsonKey        start='"' skip="\\." end='"' oneline
                        \ contains=jsonEscape,@Spell
                        \ nextgroup=jsonColon,jsonMissingCommaError skipwhite skipempty
syn match jsonEscape      "\\\%(["/\\bfnrt]\|u\x\{4}\)" contained display
syn match jsonNumber      "-\=\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\ze\%(\s*[^]},]\@!\)"
                        \ nextgroup=@jsonCommas skipwhite skipempty
syn keyword jsonBoolean   true false
                        \ nextgroup=@jsonCommas skipwhite skipempty
syn keyword jsonNull      null
                        \ nextgroup=@jsonCommas skipwhite skipempty
syn cluster jsonValue     add=jsonObject,jsonArray,jsonString,jsonNumber,jsonBoolean,jsonNull

syn sync minlines=10


hi def link jsonColon     Delimiter
hi def link jsonComma     Delimiter
hi def link jsonBracket   Delimiter
hi def link jsonString    String
hi def link jsonKey       String
hi def link jsonEscape    SpecialChar
hi def link jsonNumber    Number
hi def link jsonBoolean   Boolean
hi def link jsonNull      Constant

if b:vim_json_warnings
  hi def link jsonCommaError          ErrorMsg
  hi def link jsonNoQuoteError        Error
  hi def link jsonNumberError         Error
  hi def link jsonStringError         Error
  hi def link jsonCommentError        Error
  hi def link jsonTrailingCommaError  ErrorMsg
  hi def link jsonMissingCommaError   Error
endif

let b:current_syntax = 'json'

let &cpo = s:save_cpo
unlet s:save_cpo
