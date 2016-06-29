" Vim syntax file
" Language:     YAML
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

syntax match    yamlIndicatorError  /[@`]/ display
syntax match    yamlIndicator       /[,-:?]/ display
syntax region   yamlFlowMapping     matchgroup=yamlIndicator start=/{/ end=/}/ contains=TOP,@yamlDocumentMarkers,yamlPlain,yamlBlockScalar transparent
syntax region   yamlFlowSequence    matchgroup=yamlIndicator start=/\[/ end=/]/ contains=TOP,@yamlDocumentMarkers,yamlPlain,yamlBlockScalar transparent

syntax match    yamlPlain           /\%([^\t !"#%&'*,-:>?@[\]`{|}]\|[-:?]\S\@=\)\%([^\t #:]*\)\@>\%(\%(\%(\S\@<=#\|:\S\@=\)[^\t #:]*\|[\t ][^\t #:]\+\)*\)\@>/
syntax match    yamlPlainInFlow     /["'\]}]\@<!\%([^\t !"#%&'*,-:>?@[\]`{|}]\|[-:?][^\t ,[\]{}]\@=\)\%([^\t #,:[\]{}]*\)\@>\%(\%(\%(\S\@<=#\|:[^\t ,[\]{}]\@=\)[^\t #,:[\]{}]*\|[\t ][^\t #,:[\]{}]\+\)*\)\@>/ contained containedin=yamlFlowMapping,yamlFlowSequence
syntax region   yamlBlockScalar     start=/\%(^\z( *\)\@>.*\)\@<=[|>]\%([1-9][-+]\=\|[-+][1-9]\=\)\=/ skip=/^\z1 \|^ *$/ end=/^/ contains=yamlEscape,yamlEscapeError
syntax region   yamlSingleString    start=/'/ skip=/''/ end=/'/
syntax region   yamlDoubleString    start=/"/ skip=/\\\_./ end=/"/ contains=yamlEscape,yamlEscapeError
syntax match    yamlEscapeError     /\\\%(x.\{2}\|u.\{4}\|U.\{8}\|.\)/ contained
syntax match    yamlEscape          /\\\%(x\x\{2}\|u\x\{4}\|U\x\{8}\)/ contained
syntax match    yamlEscape          /\\[\t\n "/0LNP\\_abefnrtv]/ contained

syntax match    yamlNull            /\~/ display
syntax keyword  yamlNull            null Null NULL
syntax keyword  yamlBool            on On ON off Off OFF
syntax keyword  yamlBool            true True TRUE false False FALSE
syntax keyword  yamlBool            y Y yes Yes YES n N no No NO
syntax match    yamlInt             /[-+]\=\%(0\|[1-9][0-9_]*\%(:[0-5]\=[0-9]\)*\)/ display
syntax match    yamlInt             /[-+]\=\%(0b[01_]\+\|0[0-7_]\+\|0x[0-9A-Fa-f_]\+\)/ display
syntax match    yamlFloat           /[-+]\=\d\+[eE][-+]\=\d\+/ display
syntax match    yamlFloat           /[-+]\=\%(\.\d\+\|\d\+\.\d*\)\%([eE][-+]\=\d\+\)\=/ display
syntax match    yamlFloat           /[-+]\=\%([0-9][0-9_]*\)\=\.[0-9.]*\%([eE][-+]\d\+\)\=/ display
syntax match    yamlFloat           /[-+]\=[0-9][0-9_]*\%(:[0-5]\=[0-9]\)\+\.[0-9_]*/ display
syntax match    yamlFloat           /[-+]\=\.\%(inf\|Inf\|INF\)\|\.\%(nan\|NaN\|NAN\)/ display
syntax match    yamlTime            /\d\{4}-\d\d-\d\d/ display
syntax match    yamlTime            /\d\{4}-\d\d\=-\d\d\=\%([Tt]\|[\t ]\+\)\d\d\=:\d\d:\d\d\%(\.\d*\)\=\%([\t ]*\%(Z\|[-+]\d\d\=\%(:\d\d\)\=\)\)\=/ display

syntax match    yamlTag             /!\%(<\%([^\x00-\x20"%<>\\^`{|}\x7f-\xff]*\)\@>\%(\%(%\x\x[^\x00-\x20"%<>\\^`{|}\x7f-\xff]*\)*\)\@>>\)\=/ display
syntax match    yamlTag             /!\%(\%([-0-9A-Za-z]*\)\@>!\)\=\%([^\x00-\x22%,<>[\\\]^`{|}\x7f-\xff]\+\)\@>\%(\%(%\x\x[^\x00-\x22%,<>[\\\]^`{|}\x7f-\xff]*\)*\)\@>/ display
syntax match    yamlTagError        /!\%([-0-9A-Za-z]*\)\@>![^\x00-\x22%,<>[\\\]^`{|}\x7f-\xff]\@!/ display
syntax match    yamlAnchor          /&[^\t ,[\]{}]\+/ display
syntax match    yamlAlias           /\*[^\t ,[\]{}]\+/ display

syntax match    yamlDirective       /^%[^\t ].*$/ display contains=yamlComment
syntax match    yamlDirectivesEnd   /^---/ display
syntax match    yamlDocSuffixError  /^\.\.\./ display
syntax match    yamlDocSuffix       /^\.\.\.\ze\%([\t ]\+#.*\)\=$/ display contains=yamlComment
syntax cluster  yamlDocumentMarkers contains=yamlDirective,yamlDirectivesEnd,yamlDocumentEnd,yamlDocumentEndError

syntax case     ignore
syntax region   yamlComment         start=/\%(^\|\%([\t ]\+\)\@>\)\zs#/ end=/$/ display oneline contains=yamlTodo,@Spell
syntax keyword  yamlTodo            TODO FIXME XXX NOTE contained

highlight link  yamlIndicator       Operator
highlight link  yamlFlowMapping     Operator
highlight link  yamlFlowSequence    Operator
highlight link  yamlDoubleString    String
highlight link  yamlSingleString    String
highlight link  yamlBlockScalar     String
highlight link  yamlPlain           String
highlight link  yamlPlainInFlow     String
highlight link  yamlEscape          Special

highlight link  yamlNull            Constant
highlight link  yamlBool            Boolean
highlight link  yamlInt             Number
highlight link  yamlFloat           Float
highlight link  yamlTime            Constant

highlight link  yamlTag             Identifier
highlight link  yamlAnchor          Label
highlight link  yamlAlias           Label

highlight link  yamlDirective       Define
highlight link  yamlDirectivesEnd   Define
highlight link  yamlDocSuffix       Define

highlight link  yamlComment         Comment
highlight link  yamlTodo            Todo

highlight link  yamlDirectiveError  Error
highlight link  yamlDocSuffixError  Error
highlight link  yamlIndicatorError  Error
highlight link  yamlTagError        Error
highlight link  yamlEscapeError     Error

let b:current_syntax = 'yaml'
let &cpo = s:save_cpo
unlet s:save_cpo
