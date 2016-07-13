let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config['c/watchdogs_checker'] = {
      \   'type': 'watchdogs_checker/clang',
      \   'cmdopt': '-Wall -Wextra -std=gnu11'
      \ }
let g:quickrun_config['watchdogs_checker/gcc'] = {
      \   'command': 'gcc',
      \   'exec': '%c %o -fsyntax-only %s:p'
      \ }
let g:quickrun_config['watchdogs_checker/clang'] = {
      \   'command': 'clang',
      \   'exec': '%c %o -fsyntax-only %s:p'
      \ }
let g:quickrun_config['cpp/watchdogs_checker'] = {
      \   'type': 'watchdogs_checker/clang++',
      \   'cmdopt': '-Wall -Wextra -std=gnu++14'
      \ }
let g:quickrun_config['watchdogs_checker/g++'] = {
      \   'command': 'g++',
      \   'exec': '%c %o -fsyntax-only %s:p'
      \ }
let g:quickrun_config['watchdogs_checker/clang++'] = {
      \   'command': 'clang++',
      \   'exec': '%c %o -fsyntax-only %s:p'
      \ }
let g:quickrun_config['javascript/watchdogs_checker'] = {
      \   'type': 'watchdogs_checker/eslint'
      \ }

let g:watchdogs_check_BufWritePost_enables = {
      \   'c': 1,
      \   'cpp': 1,
      \   'javascript': 1
      \ }

call watchdogs#setup(g:quickrun_config)
