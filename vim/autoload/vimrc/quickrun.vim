function vimrc#quickrun#on_source() abort
  let g:quickrun_no_default_key_mappings = 1
  let g:quickrun_config = {
    \   '_': {
    \     'runner': 'job',
    \     'outputter': 'buffer',
    \     'outputter/buffer/running_mark': '[quickrun running...]',
    \     'outputter/buffer/close_on_empty': 1,
    \   },
    \   'c': { 'type': 'c/clang' },
    \   'c/gcc': {
    \     'exec': ['%c %o %s -o %s:r', '%s:p:r %a'],
    \     'command': 'gcc',
    \     'cmdopt': '-O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.c',
    \     'hook/sweep/files': '%S:p:r',
    \   },
    \   'c/clang': {
    \     'exec': ['%c %o %s -o %s:r', '%s:p:r %a'],
    \     'command': 'clang',
    \     'cmdopt': '-O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.c',
    \     'hook/sweep/files': '%S:p:r',
    \   },
    \   'c/gcc-asm': {
    \     'exec': '%c -S %o %s -o -',
    \     'command': 'gcc',
    \     'cmdopt': '-O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.c',
    \   },
    \   'c/clang-asm': {
    \     'exec': '%c -S %o %s -o -',
    \     'command': 'clang',
    \     'cmdopt': '-O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.c',
    \   },
    \   'c/clang-llvm': {
    \     'exec': '%c -S -emit-llvm %o %s -o -',
    \     'command': 'clang',
    \     'cmdopt': '-O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.c',
    \   },
    \   'cpp': { 'type': 'cpp/g++' },
    \   'cpp/g++': {
    \     'exec': ['%c %o %s -o %s:r', '%s:p:r %a'],
    \     'command': 'g++',
    \     'cmdopt': '-std=gnu++20 -O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.cpp',
    \     'hook/sweep/files': '%S:p:r',
    \   },
    \   'cpp/clang++': {
    \     'exec': ['%c %o %s -o %s:r', '%s:p:r %a'],
    \     'command': 'clang++',
    \     'cmdopt': '-std=gnu++20 -O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.cpp',
    \     'hook/sweep/files': '%S:p:r',
    \   },
    \   'cpp/g++-asm': {
    \     'exec': '%c -S %o %s -o -',
    \     'command': 'g++',
    \     'cmdopt': '-std=gnu++20 -O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.cpp',
    \   },
    \   'cpp/clang++-asm': {
    \     'exec': '%c -S %o %s -o -',
    \     'command': 'clang++',
    \     'cmdopt': '-std=gnu++20 -O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.cpp',
    \   },
    \   'cpp/clang++-llvm': {
    \     'exec': '%c -S -emit-llvm %o %s -o -',
    \     'command': 'clang++',
    \     'cmdopt': '-std=gnu++20 -O2 -march=native -pipe -Wextra',
    \     'tempfile': '%{tempname()}.cpp',
    \   },
    \   'vim/vimscript': {
    \     'runner': 'vimscript',
    \   },
    \ }
endfunction
