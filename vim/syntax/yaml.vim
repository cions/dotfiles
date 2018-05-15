" Vim syntax file
" Language:    YAML 1.2
" Maintainer:  cions <gh.cions@gmail.com>
" Last Change: 2018-04-26

if exists('b:current_syntax')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('b:yaml_schema')
  let b:yaml_schema = get(g:, 'yaml_schema', 'core')
endif

syn case match

syn match yamlReservedIndicator     "[@`]" display
syn match yamlExplicitKeyIndicator  "?" contained display
syn match yamlKeyValueDelimiter     ":" contained display
syn match yamlFlowIndicator         "," contained display
syn cluster yamlIndicators          add=yamlReservedIndicator,yamlExplicitKeyIndicator,yamlKeyValueDelimiter,yamlFlowIndicator

syn match yamlTag                   "!" display
syn match yamlTag                   "!\%([-[:alnum:]]*!\)\=\%(%\x\x\|[-[:alnum:]#;/?:@&=+$_.~*'()]\)\+" display
syn match yamlTagError              "![-[:alnum:]]*!\%(%\x\x\|[-[:alnum:]#;/?:@&=+$_.~*'()]\)\@!" display
syn match yamlTag                   "!<\%(%\x\x\|[-[:alnum:]#;/?:@&=+$,_.!~*'()[\]]\)\+>" display
syn match yamlAnchor                "&[^[:blank:],[\]{}]\+" display
syn match yamlAlias                 "\*[^[:blank:],[\]{}]\+" display
syn cluster yamlProperties          add=yamlTag,yamlTagError,yamlAnchor,yamlAlias

syn match yamlFlowPlain             "\%([^ \t\-?:,[\]{}#&*!|>'"%@`]\|[-?:][^ \t,[\]{}]\@=\)\%(\%([^ \t,[\]{}#:]\|\S\@1<=#\|:[^ \t,[\]{}]\@=\)*\)\@>\%(\%(\s\+\)\@>\%(\%([^ \t,[\]{}#:]\|\S\@1<=#\|:[^ \t,[\]{}]\@=\)\+\)\@>\)*"
                                  \ contained
syn match yamlFlowPlainKey          "\%([^ \t\-?:,[\]{}#&*!|>'"%@`]\|[-?:][^ \t,[\]{}]\@=\)\%(\%([^ \t,[\]{}#:]\|\S\@1<=#\|:[^ \t,[\]{}]\@=\)*\)\@>\%(\%(\%(\s\+\)\@>\%(\%([^ \t,[\]{}#:]\|\S\@1<=#\|:[^ \t,[\]{}]\@=\)\+\)\@>\)*\)\@>\ze\s*:"
                                  \ nextgroup=yamlKeyValueDelimiter skipwhite
                                  \ contained
syn region yamlDoubleString         matchgroup=yamlDoubleString start='"' skip="\\." end='"'
                                  \ contains=yamlDoubleEscape extend
                                  \ nextgroup=yamlKeyValueDelimiter skipwhite
syn match yamlDoubleEscape          "\\\%([ \t"/0LNP\\_abefnrtv]\|x\x\{2}\|u\x\{4}\|U\x\{8}\|$\)"
                                  \ contained display
syn region yamlSingleString         matchgroup=yamlSingleString start="'" skip="''" end="'"
                                  \ contains=yamlSingleEscape extend
                                  \ nextgroup=yamlKeyValueDelimiter skipwhite
syn match yamlSingleEscape          "''" contained display
syn cluster yamlFlow                add=yamlFlowPlain,yamlFlowPlainKey,yamlDoubleString,yamlSingleString

syn region yamlFlowSeq              matchgroup=yamlFlowIndicator start="\[" end="]"
                                  \ contains=@yamlFlow,@yamlProperties,@yamlIndicators,yamlComment
                                  \ nextgroup=yamlKeyValueDelimiter skipwhite
                                  \ extend transparent
syn region yamlFlowMap              matchgroup=yamlFlowIndicator start="{" end="}"
                                  \ contains=@yamlFlow,@yamlProperties,@yamlIndicators,yamlComment
                                  \ nextgroup=yamlKeyValueDelimiter skipwhite
                                  \ extend transparent
syn cluster yamlFlow                add=yamlFlowSeq,yamlFlowMap

syn match yamlBlockPlain            "\%([^ \t\-?:,[\]{}#&*!|>'"%@`]\|[-?:][^ \t,[\]{}]\@=\)\%(\%([^ \t#:]\|\S\@1<=#\|:\S\@=\)*\)\@>\%(\%(\s\+\)\@>\%(\%([^ \t#:]\|\S\@1<=#\|:\S\@=\)\+\)\@>\)*"
syn match yamlBlockPlainKey         "\%([^ \t\-?:,[\]{}#&*!|>'"%@`]\|[-?:][^ \t,[\]{}]\@=\)\%(\%([^ \t#:]\|\S\@1<=#\|:\S\@=\)*\)\@>\%(\%(\%(\s\+\)\@>\%(\%([^ \t#:]\|\S\@1<=#\|:\S\@=\)\+\)\@>\)*\)\@>\ze\s*:"
                                  \ nextgroup=yamlKeyValueDelimiter skipwhite

syn match yamlBlockScalarHeader     "[|>]\%([1-9][+-]\=\|[+-][1-9]\=\)\=\%(\s\+#.*\|\s*\)$"
                                  \ contains=yamlComment nextgroup=yamlBlockScalar skipnl
syn region yamlBlockScalar          start="^\S\@!" end="^\S\@=" contained
syn match yamlBlockScalarHeader     "\%(^\%(---\s\+\|\s*\)\)\@<=[|>]\%([1-9][+-]\=\|[+-][1-9]\=\)\=\%(\s\+#.*\|\s*\)$"
                                  \ contains=yamlComment nextgroup=yamlBlockScalarTop skipnl
syn region yamlBlockScalarTop       start="^\%(\%(---\|\.\.\.\)\%($\|\s\)\)\@!" end="^\%(\%(---\|\.\.\.\)\%($\|\s\)\)\@="
                                  \ contained
syn cluster yamlBlock               add=yamlBlockPlain,yamlBlockPlainKey,yamlBlockScalarHeader

syn region yamlBlockMapValue        matchgroup=yamlKeyValueDelimiter start="^\z( *\):"
                                  \ matchgroup=NONE skip="^\%(\s*\%(#.*\)\=$\|\z1 \)" end="^"
                                  \ contains=@yamlBlock,@yamlFlow,@yamlProperties,yamlReservedIndicator,yamlComment
                                  \ contained transparent

for s:i in range(9, 1, -1)
  let s:prefix = '\%(^\z( *\)' . repeat('[-?:]\z( \+\)', s:i - 1) . '\)\@<='
  let s:indent = join(map(range(1, s:i), 'printf("\\z%d", v:val)'), ' ')
  exe 'syn region yamlBlockImplicitMap'
        \ 'start="' . s:prefix . '\%(\S\@=.*:\S\@!\)"'
        \ 'skip="^\%(\s*\%(#.*\)\=$\|' . s:indent . '\%( \|-\S\@!\)\)"'
        \ 'end="^" keepend transparent'
        \ 'contains=@yamlBlock,@yamlFlow,@yamlProperties,yamlReservedIndicator,yamlKeyValueDelimiter,yamlComment'
  exe 'syn region yamlBlockExplicitMap'
        \ 'matchgroup=yamlExplicitKeyIndicator start="' . s:prefix . '?\S\@!"'
        \ 'matchgroup=NONE skip="^\%(\s*\%(#.*\)\=$\|' . s:indent . ' \)"'
        \ 'end="^" keepend transparent'
        \ 'contains=@yamlBlock,@yamlFlow,@yamlProperties,yamlReservedIndicator,yamlComment'
        \ 'nextgroup=yamlBlockMapValue'
  exe 'syn region yamlBlockSeq'
        \ 'matchgroup=yamlBlockSeqIndicator start="' . s:prefix . '-\S\@!"'
        \ 'matchgroup=NONE skip="^\%(\s*\%(#.*\)\=$\|' . s:indent . ' \)"'
        \ 'end="^" keepend transparent'
        \ 'contains=@yamlBlock,@yamlFlow,@yamlProperties,yamlReservedIndicator,yamlComment'
endfor
syn cluster yamlBlock               add=yamlBlockImplicitMap,yamlBlockExplicitMap,yamlBlockSeq

syn region yamlComment              start="\%(^\|\s\+\)\@<=#" end="$" display oneline contains=yamlTodo,@Spell
syn keyword yamlTodo                contained TODO FIXME XXX NOTE

syn match yamlReservedDirective     "^%.*" contained display
syn match yamlTagPrefix             "\%(%\x\x\|[-[:alnum:]#;/?:@&=+$_.!~*'()]\)\%(%\x\x\|[-[:alnum:]#;/?:@&=+$,_.!~*'()[\]]\)*"
                                  \ contained display nextgroup=yamlComment skipwhite
syn match yamlTagHandle             "!\%([-[:alnum:]]*!\)\=\s\@=" contained display nextgroup=yamlTagPrefix skipwhite
syn match yamlTAGDirective          "^%TAG\s\@=" contained display nextgroup=yamlTagHandle skipwhite
syn match yamlYAMLVersion           "\d\+\.\d\+" contained display nextgroup=yamlComment skipwhite
syn match yamlYAMLDirective         "^%YAML\s\@=" contained display nextgroup=yamlYAMLVersion skipwhite
syn cluster yamlDirectives          add=yamlYAMLDirective,yamlTAGDirective,yamlReservedDirective
syn match yamlDocumentEnd           "^\.\.\.\%($\|\s\)\@=" contained
syn match yamlDirectivesEnd         "^---\%($\|\s\)\@="
syn region yamlDirectivesRegion     start="\%^\%([[:space:]%#]\|---\%($\|\s\)\)\@="
                                  \ start="^\%(\.\.\.\%($\|\s\)\)\@="
                                  \ skip="^\%(%.*\|\.\.\.\%(\s.*\)\=\|\s*\%(#.*\)\=\)$"
                                  \ end="^\%(---\%($\|\s\)\@=\)\="
                                  \ contains=@yamlDirectives,yamlDocumentEnd,yamlDirectivesEnd,yamlComment
                                  \ keepend

let s:flow_end = '\%(\%(\s*\)\@>\%($\|[,[\]{}]\|\s\@1<=#\|:[^ \t,[\]{}]\@!\)\)\@='
let s:block_end = '\%(\s*$\|\s\+#\|\s*:\S\@!\)\@='
function! s:define_special(name, pattern) abort
  exe 'syn match yamlFlow' . a:name . ' "\%(' . a:pattern . '\)' . s:flow_end . '"'
        \ 'contained nextgroup=yamlKeyValueDelimiter skipwhite'
  exe 'syn match yamlBlock' . a:name . ' "\%(' . a:pattern . '\)' . s:block_end . '"'
        \ 'nextgroup=yamlKeyValueDelimiter skipwhite'
  exe 'syn cluster yamlFlowSpecial add=yamlFlow' . a:name
  exe 'syn cluster yamlBlockSpecial add=yamlBlock' . a:name
endfunction

if b:yaml_schema ==# 'json'
  call s:define_special('Float', '-\=\%(0\|[1-9]\d*\)\%(\.\d*\)\=\%([eE][-+]\=\d\+\)\=')
  call s:define_special('Integer', '-\=\%(0\|[1-9]\d*\)')
  call s:define_special('Bool', 'true\|false')
  call s:define_special('Null', 'null')
elseif b:yaml_schema ==# 'core'
  call s:define_special('Float', '[-+]\=\.\%(inf\|Inf\|INF\)\|\.\%(nan\|NaN\|NAN\)')
  call s:define_special('Float', '[-+]\=\%(\.\d\+\|\d\+\%(\.\d*\)\=\)\%([eE][-+]\=\d\+\)\=')
  call s:define_special('Integer', '[-+]\=\d\+\|0\%(o\o\+\|x\x\+\)')
  call s:define_special('Bool', 'true\|True\|TRUE\|false\|False\|FALSE')
  call s:define_special('Null', 'null\|Null\|NULL\|\~')
elseif b:yaml_schema ==# 'pyyaml'
  call s:define_special('Timestamp', '\d\d\d\d-\d\d\=-\d\d\=\%([tT]\|\s\+\)\d\d\=:\d\d:\d\d\%(\.\d*\)\=\%(\s*\%(Z\|[-+]\d\d\=\%(:\d\d\)\=\)\)\=')
  call s:define_special('Timestamp', '\d\d\d\d-\d\d-\d\d')
  call s:define_special('Float', '[-+]\=\.\%(inf\|Inf\|INF\)\|\.\%(nan\|NaN\|NAN\)')
  call s:define_special('Float', '[-+]\=\d[[:digit:]_]*\%([0-5]\=\d\)\+\.[[:digit:]_]*')
  call s:define_special('Float', '[-+]\=\%(\d[[:digit:]_]*\.[[:digit:]_]*\|\.[[:digit:]_]\+\)\%([eE][-+]\=\d\+\)\=')
  call s:define_special('Integer', '[-+]\=0\%([0-7_]\+\|x[[:xdigit:]_]\+\|b[01_]\+\)')
  call s:define_special('Integer', '[-+]\=\%(0\|[1-9][[:digit:]_]*\)\%(:[0-5]\=\d\)*')
  call s:define_special('Bool', 'on\|On\|ON\|off\|Off\|OFF')
  call s:define_special('Bool', 'true\|True\|TRUE\|false\|False\|FALSE')
  call s:define_special('Bool', 'yes\|Yes\|YES\|no\|No\|NO')
  call s:define_special('Null', 'null\|Null\|NULL\|\~')
endif
syn cluster yamlFlow add=@yamlFlowSpecial
syn cluster yamlBlock add=@yamlBlockSpecial

syn sync minlines=50

hi def link yamlReservedIndicator         Error
hi def link yamlExplicitKeyIndicator      Delimiter
hi def link yamlKeyValueDelimiter         Delimiter
hi def link yamlBlockSeqIndicator         Delimiter
hi def link yamlFlowIndicator             Delimiter

hi def link yamlTag                       Type
hi def link yamlTagError                  Error
hi def link yamlAnchor                    Type
hi def link yamlAlias                     Type

hi def link yamlFlowPlainKey              Identifier
hi def link yamlDoubleString              String
hi def link yamlDoubleEscape              SpecialChar
hi def link yamlSingleString              String
hi def link yamlSingleEscape              SpecialChar

hi def link yamlBlockPlainKey             Identifier
hi def link yamlBlockScalarHeader         String

hi def link yamlComment                   Comment
hi def link yamlTodo                      Todo

hi def link yamlReservedDirective         Error
hi def link yamlTagPrefix                 Type
hi def link yamlTagHandle                 Type
hi def link yamlTAGDirective              PreProc
hi def link yamlYAMLVersion               Number
hi def link yamlYAMLDirective             PreProc
hi def link yamlDocumentEnd               PreProc
hi def link yamlDirectivesEnd             PreProc
hi def link yamlDirectivesRegion          Error

hi def link yamlNull                      Constant
hi def link yamlBool                      Boolean
hi def link yamlInteger                   Number
hi def link yamlFloat                     Float
hi def link yamlTimestamp                 Constant

hi def link yamlFlowNull                  yamlNull
hi def link yamlFlowBool                  yamlBool
hi def link yamlFlowInteger               yamlInteger
hi def link yamlFlowFloat                 yamlFloat
hi def link yamlFlowTimestamp             yamlTimestamp

hi def link yamlBlockNull                 yamlNull
hi def link yamlBlockBool                 yamlBool
hi def link yamlBlockInteger              yamlInteger
hi def link yamlBlockFloat                yamlFloat
hi def link yamlBlockTimestamp            yamlTimestamp

let b:current_syntax = 'yaml'

let &cpo = s:save_cpo
unlet s:save_cpo s:i s:prefix s:indent s:flow_end s:block_end
