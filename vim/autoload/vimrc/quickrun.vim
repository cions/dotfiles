scriptversion 4

function vimrc#quickrun#setup() abort
  nnoremap <silent> \r :<C-U>QuickRun<CR>

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
        \     'exec': ['%c %o -o %s:r %s', '%s:p:r %a'],
        \     'command': 'gcc',
        \     'cmdopt': '-O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.c',
        \     'hook/sweep/files': '%S:p:r',
        \   },
        \   'c/clang': {
        \     'exec': ['%c %o -o %s:r %s', '%s:p:r %a'],
        \     'command': 'clang',
        \     'cmdopt': '-O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.c',
        \     'hook/sweep/files': '%S:p:r',
        \   },
        \   'c/gcc-asm': {
        \     'exec': '%c -S %o -o - %s',
        \     'command': 'gcc',
        \     'cmdopt': '-O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.c',
        \   },
        \   'c/clang-asm': {
        \     'exec': '%c -S %o -o - %s',
        \     'command': 'clang',
        \     'cmdopt': '-O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.c',
        \   },
        \   'c/clang-llvm': {
        \     'exec': '%c -S -emit-llvm %o -o - %s',
        \     'command': 'clang',
        \     'cmdopt': '-O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.c',
        \   },
        \   'cpp': { 'type': 'cpp/clang++' },
        \   'cpp/g++': {
        \     'exec': ['%c %o -o %s:r %s', '%s:p:r %a'],
        \     'command': 'g++',
        \     'cmdopt': '-std=gnu++23 -O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.cpp',
        \     'hook/sweep/files': '%S:p:r',
        \   },
        \   'cpp/clang++': {
        \     'exec': ['%c %o -o %s:r %s', '%s:p:r %a'],
        \     'command': 'clang++',
        \     'cmdopt': '-std=gnu++23 -O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.cpp',
        \     'hook/sweep/files': '%S:p:r',
        \   },
        \   'cpp/g++-asm': {
        \     'exec': '%c -S %o -o - %s',
        \     'command': 'g++',
        \     'cmdopt': '-std=gnu++23 -O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.cpp',
        \   },
        \   'cpp/clang++-asm': {
        \     'exec': '%c -S %o -o - %s',
        \     'command': 'clang++',
        \     'cmdopt': '-std=gnu++23 -O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.cpp',
        \   },
        \   'cpp/clang++-llvm': {
        \     'exec': '%c -S -emit-llvm %o -o - %s',
        \     'command': 'clang++',
        \     'cmdopt': '-std=gnu++23 -O2 -march=native -pipe',
        \     'tempfile': '%{tempname()}.cpp',
        \   },
        \   'vim/vimscript': {
        \     'runner': 'vimscript',
        \   },
        \ }
endfunction
