let g:quickrun_no_default_key_mappings = 1

let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config['_'] = {
      \   'runner': 'vimproc',
      \   'runner/vimproc/updatetime': 100,
      \   'outputter': 'buffer',
      \   'outputter/buffer/into': 1,
      \   'outputter/buffer/running_mark': '[running...]'
      \ }
let g:quickrun_config['c'] = { 'type': 'c/clang' }
let g:quickrun_config['c/gcc'] = {
      \   'command': 'gcc',
      \   'exec': ['%c %o -o %s:p:r %s', '%s:p:r %a'],
      \   'cmdopt': '-Wall -Wextra -std=gnu11 -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.c',
      \   'hook/sweep/files': ['%S:p:r']
      \ }
let g:quickrun_config['c/clang'] = {
      \   'command': 'clang',
      \   'exec': ['%c %o -o %s:p:r %s', '%s:p:r %a'],
      \   'cmdopt': '-Wall -Wextra -std=gnu11 -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.c',
      \   'hook/sweep/files': ['%S:p:r']
      \ }
let g:quickrun_config['c/llvm-ir'] = {
      \   'command': 'clang',
      \   'exec': '%c %o -emit-llvm -S -o - %s',
      \   'cmdopt': '-Wall -Wextra -std=gnu11 -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.c',
      \   'outputter/buffer/filetype': 'llvm'
      \ }
let g:quickrun_config['c/asm'] = {
      \   'command': 'clang',
      \   'exec': '%c %o -S -o - %s',
      \   'cmdopt': '-Wall -Wextra -std=gnu11 -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.c',
      \   'outputter/buffer/filetype': 'asm'
      \ }
let g:quickrun_config['cpp'] = { 'type': 'cpp/clang++' }
let g:quickrun_config['cpp/g++'] = {
      \   'command': 'g++',
      \   'exec': ['%c %o -o %s:p:r %s', '%s:p:r %a'],
      \   'cmdopt': '-Wall -Wextra -std=gnu++14 -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.cpp',
      \   'hook/sweep/files': ['%S:p:r']
      \ }
let g:quickrun_config['cpp/clang++'] = {
      \   'command': 'clang++',
      \   'exec': ['%c %o -o %s:p:r %s', '%s:p:r %a'],
      \   'cmdopt': '-Wall -Wextra -std=gnu++14 -stdlib=libc++ -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.cpp',
      \   'hook/sweep/files': ['%S:p:r']
      \ }
let g:quickrun_config['cpp/llvm-ir'] = {
      \   'command': 'clang++',
      \   'exec': '%c %o -emit-llvm -S -o - %s',
      \   'cmdopt': '-Wall -Wextra -std=gnu++14 -stdlib=libc++ -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.cpp',
      \   'outputter/buffer/filetype': 'llvm'
      \ }
let g:quickrun_config['cpp/asm'] = {
      \   'command': 'clang++',
      \   'exec': '%c %o -S -o - %s',
      \   'cmdopt': '-Wall -Wextra -std=gnu++14 -stdlib=libc++ -march=native -O2 -pipe',
      \   'tempfile': '%{tempfile()}.cpp',
      \   'outputter/buffer/filetype': 'asm'
      \ }
let g:quickrun_config['javascript'] = { 'type': 'javascript/nodejs' }
let g:quickrun_config['markdown'] = {
      \   'type': 'markdown/pandoc',
      \   'cmdopt': '-s',
      \   'outputter': 'browser'
      \ }
