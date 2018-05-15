function! vimrc#lexima#on_post_source() abort
  call lexima#set_default_rules()

  call lexima#add_rule({
        \ 'char': ')',
        \ 'at': '\%#\_s*)',
        \ 'leave': ')' })
  call lexima#add_rule({
        \ 'char': ']',
        \ 'at': '\%#\_s*]',
        \ 'leave': ']' })
  call lexima#add_rule({
        \ 'char': '}',
        \ 'at': '\%#\_s*}',
        \ 'leave': '}' })

  call lexima#add_rule({
        \ 'char': '<Bar>',
        \ 'at': '\%(do\|{\)\s*\%#',
        \ 'input': '|',
        \ 'input_after': '|',
        \ 'filetype': ['ruby'] })
  call lexima#add_rule({
        \ 'char': '<Bar>',
        \ 'at': '\%#|',
        \ 'leave': 1,
        \ 'filetype': ['ruby'] })
  call lexima#add_rule({
        \ 'char': '<BS>',
        \ 'at': '|\%#|',
        \ 'input': '<BS>',
        \ 'delete': 1,
        \ 'filetype': ['ruby'] })
  call lexima#add_rule({
        \ 'char': '<CR>',
        \ 'at': '|\%#}',
        \ 'input': '<CR>',
        \ 'input_after': '<CR>',
        \ 'filetype': ['ruby'] })

  call lexima#add_rule({
        \ 'char': '(',
        \ 'at': '\\left\%#',
        \ 'input': '(',
        \ 'input_after': '\right)',
        \ 'filetype': ['tex', 'plaintex'] })
  call lexima#add_rule({
        \ 'char': '[',
        \ 'at': '\\left\%#',
        \ 'input': '[',
        \ 'input_after': '\right]',
        \ 'filetype': ['tex', 'plaintex'] })
  call lexima#add_rule({
        \ 'char': '{',
        \ 'at': '\\left\%#',
        \ 'input': '\{',
        \ 'input_after': '\right\}',
        \ 'filetype': ['tex', 'plaintex'] })

  augroup lexima-expand
    au!
    au FileType ruby inoremap <buffer><expr> <Bar> lexima#expand('<Bar>', 'i')
  augroup END
endfunction
