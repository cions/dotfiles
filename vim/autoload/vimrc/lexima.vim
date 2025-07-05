scriptversion 4

function vimrc#lexima#setup() abort
  imap <S-CR> <CR>

  let g:lexima_no_default_rules = 1
  let g:lexima_accept_pum_with_enter = 1

  call lexima#clear_rules()

  " auto paren
  call lexima#add_rule(#{ char: '(', input_after: ')' })
  call lexima#add_rule(#{ char: '(', at: '\\\%#' })
  call lexima#add_rule(#{ char: ')', at: '\%#)', leave: 1 })
  call lexima#add_rule(#{ char: '<BS>', at: '(\%#)', delete: 1 })
  call lexima#add_rule(#{ char: '{', input_after: '}' })
  call lexima#add_rule(#{ char: '{', at: '\\\%#' })
  call lexima#add_rule(#{ char: '}', at: '\%#}', leave: 1 })
  call lexima#add_rule(#{ char: '<BS>', at: '{\%#}', delete: 1 })
  call lexima#add_rule(#{ char: '[', input_after: ']' })
  call lexima#add_rule(#{ char: '[', at: '\\\%#' })
  call lexima#add_rule(#{ char: ']', at: '\%#]', leave: 1 })
  call lexima#add_rule(#{ char: '<BS>', at: '\[\%#\]', delete: 1 })

  " auto quote
  call lexima#add_rule(#{ char: '"', input_after: '"' })
  call lexima#add_rule(#{ char: '"', at: '\\\%#' })
  call lexima#add_rule(#{ char: '"', at: '^\s*\%#', filetype: ['vim'] })
  call lexima#add_rule(#{ char: '"', at: '\%#\s*$', filetype: ['vim'] })
  call lexima#add_rule(#{ char: '"', at: '\%#"', leave: 1 })
  call lexima#add_rule(#{ char: '<BS>', at: '"\%#"', delete: 1 })
  call lexima#add_rule(#{ char: '"', at: '""\%#', input_after: '"""' })
  call lexima#add_rule(#{ char: '"', at: '\%#"""', leave: 3 })
  call lexima#add_rule(#{ char: '<BS>', at: '"""\%#"""', input: '<BS><BS><BS>', delete: 3 })
  call lexima#add_rule(#{ char: "'", input_after: "'" })
  call lexima#add_rule(#{ char: "'", at: '\\\%#' })
  call lexima#add_rule(#{ char: "'", at: '\w\%#''\@!' })
  call lexima#add_rule(#{ char: "'", at: '\<[BFRUbfru]\+\%#', input_after: "'", filetype: ['python'] })
  call lexima#add_rule(#{ char: "'", filetype: ['clojure', 'haskell', 'lisp', 'ocaml', 'rust', 'scala', 'scheme'] })
  call lexima#add_rule(#{ char: "'", at: '\%#''', leave: 1 })
  call lexima#add_rule(#{ char: "'", at: '\\\%#''', leave: 1, filetype: ['csh', 'sh', 'tcsh', 'vim', 'zsh'] })
  call lexima#add_rule(#{ char: '<BS>', at: "'\\%#'", delete: 1 })
  call lexima#add_rule(#{ char: "'", at: "''\\%#", input_after: "'''" })
  call lexima#add_rule(#{ char: "'", at: "''\\%#", input_after: "'", filetype: ['csh', 'sh', 'tcsh', 'vim', 'zsh'] })
  call lexima#add_rule(#{ char: "'", at: "\\%#'''", leave: 3 })
  call lexima#add_rule(#{ char: '<BS>', at: "'''\\%#'''", input: '<BS><BS><BS>', delete: 3 })
  call lexima#add_rule(#{ char: '`', input_after: '`' })
  call lexima#add_rule(#{ char: '`', filetype: ['ocaml', 'scheme'] })
  call lexima#add_rule(#{ char: '`', at: '\%#`', leave: 1 })
  call lexima#add_rule(#{ char: '<BS>', at: '`\%#`', delete: 1 })
  call lexima#add_rule(#{ char: '`', at: '``\%#', input_after: '```' })
  call lexima#add_rule(#{ char: '`', at: '\%#```', leave: 3 })
  call lexima#add_rule(#{ char: '<BS>', at: '```\%#```', input: '<BS><BS><BS>', delete: 3 })

  " newline rules
  call lexima#add_rule(#{ char: '<CR>', at: '(\%#)', input_after: '<CR>' })
  call lexima#add_rule(#{ char: '<CR>', at: '{\%#}', input_after: '<CR>' })
  call lexima#add_rule(#{ char: '<CR>', at: '\[\%#\]', input_after: '<CR>' })
  call lexima#add_rule(#{ char: '<CR>', at: '"""\%#"""', input: '<CR>', input_after: '<CR>' })
  call lexima#add_rule(#{ char: '<CR>', at: "'''\\%#'''", input: '<CR>', input_after: '<CR>' })
  call lexima#add_rule(#{ char: '<CR>', at: '```[-[:alnum:].:_]*\%#```', input: '<CR>', input_after: '<CR>' })

  " space rules
  call lexima#add_rule(#{ char: '<Space>', at: '(\%#)', input_after: '<Space>' })
  call lexima#add_rule(#{ char: ')', at: '\%# )', leave: 2 })
  call lexima#add_rule(#{ char: '<BS>', at: '( \%# )', delete: 1 })
  call lexima#add_rule(#{ char: '<Space>', at: '{\%#}', input_after: '<Space>' })
  call lexima#add_rule(#{ char: '}', at: '\%# }', leave: 2 })
  call lexima#add_rule(#{ char: '<BS>', at: '{ \%# }', delete: 1 })
  call lexima#add_rule(#{ char: '<Space>', at: '\[\%#\]', input_after: '<Space>' })
  call lexima#add_rule(#{ char: ']', at: '\%# \]', leave: 2 })
  call lexima#add_rule(#{ char: '<BS>', at: '\[ \%# \]', delete: 1 })

  " vim
  call lexima#add_rule(s:endwise_rule('^\s*\(def\|for\|fu\%[nction]\|if\|try\|wh\%[ile]\)\>.*\%#$', 'end\1', ['vim'], #{ with_submatch: 1 }))
  call lexima#add_rule(s:endwise_rule('^\s*augroup\>.*\%#$', 'augroup END', ['vim']))

  " ruby
  call lexima#add_rule(s:endwise_rule('^\s*\%(case\|class\|def\|for\|if\|module\|unless\|until\|while\)\>\%(.*[^.:@$]\<end\>\)\@!.*\%#$', 'end', ['ruby']))
  call lexima#add_rule(s:endwise_rule('^\s*begin\s*\%#$', 'end', ['ruby']))
  call lexima#add_rule(s:endwise_rule('\<\%(if\|unless\)\>.*\%#$', 'end', ['ruby'], #{ syntax: ['rubyConditionalExpression'] }))
  call lexima#add_rule(s:endwise_rule('\<do\>\s*\%(|.*|\s*\)\=\%#$', 'end', ['ruby']))
  call lexima#add_rule(#{ char: '<CR>', at: '\<do\>\s*\%#$', filetype: ['ruby'], syntax: ['rubyComment'] })

  call lexima#add_rule(#{ char: '<Bar>', at: '\%(do\|{\)\s*\%#', input: '<Bar>', input_after: '<Bar>', filetype: ['ruby'] })
  call lexima#add_rule(#{ char: '<Bar>', at: '\%#|', leave: 1, filetype: ['ruby'] })
  call lexima#add_rule(#{ char: '<BS>', at: '|\%#|', input: '<BS>', delete: 1, filetype: ['ruby'] })
  call lexima#add_rule(#{ char: '<Space>', at: '{|[^|]*|\%#}', input_after: '<Space>', filetype: ['ruby'] })
  call lexima#add_rule(#{ char: '<BS>', at: '{|[^|]*| \%# }', input: '<BS>', delete: 1, filetype: ['ruby'] })

  " sh
  call lexima#add_rule(s:endwise_rule('^\s*if\>.*\%#$', 'fi', ['sh', 'zsh']))
  call lexima#add_rule(s:endwise_rule('^\s*case\>.*\%#$', 'esac', ['sh', 'zsh']))
  call lexima#add_rule(s:endwise_rule('\%(^\s*\|;\s*\)do\s*\%#$', 'done', ['sh', 'zsh']))
  call lexima#add_rule(s:endwise_rule('<\@<!<<\%(\([A-Z]\+\)\|"\([A-Z]\+\)"\|''\([A-Z]\+\)''\).*\%#$', '\1\2\3', ['sh', 'zsh'], #{ with_submatch: 1 }))

  " lua
  call lexima#add_rule(s:endwise_rule('\<function\>\%(.*\<end\>\)\@!.*\%#$', 'end', ['lua']))
  call lexima#add_rule(s:endwise_rule('\<\%(do\|then\)\>\s*\%#$', 'end', ['lua']))
  call lexima#add_rule(#{ char: '<CR>', at: '\<function\>\%(.*\<end\>\)\@!.*\%#$', filetype: ['lua'], syntax: ['luaComment'] })
  call lexima#add_rule(#{ char: '<CR>', at: '\<\%(do\|then\)\>\s*\%#$', filetype: ['lua'], syntax: ['luaComment'] })

  " tex
  call lexima#add_rule(#{ char: '(', at: '\\left\%#', input: '(', input_after: '\right)', filetype: ['plaintex', 'tex'] })
  call lexima#add_rule(#{ char: '{', at: '\\left\%#', input: '\{', input_after: '\right\}', filetype: ['plaintex', 'tex'] })
  call lexima#add_rule(#{ char: '[', at: '\\left\%#', input: '[', input_after: '\right]', filetype: ['plaintex', 'tex'] })

  call lexima#add_rule(#{ char: '}', at: '\\begin{\(\w\+\*\=\)\%#', leave: 1, input_after: '\\end{\1}', filetype: ['plaintex', 'tex'], with_submatch: 1 })
  call lexima#add_rule(#{ char: '<CR>', at: '\%#\\end{', input: '<CR>', input_after: '<CR>', filetype: ['plaintex', 'tex'] })

  " html,xml
  call lexima#add_rule(#{ char: '>', at: '<\([^[:blank:]>]\+\)\s*[^>]*\%#', input_after: '</\1>', filetype: ['html', 'xml'], with_submatch: 1 })
endfunction

function s:endwise_rule(at, end, filetype, ...) abort
  let params = get(a:000, 0, {})
  return extend(#{ char: '<CR>', at: a:at, input: '<CR>', input_after: '<CR>' .. a:end, filetype: a:filetype }, params)
endfunction
