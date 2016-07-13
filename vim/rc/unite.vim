call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_selecta'])

call unite#custom#profile('default', 'context', {
      \   'start_insert': 1,
      \   'ignorecase': 1,
      \   'smartcase': 1,
      \   'winheight': 10
      \ })

call unite#custom#source('file/async,file_rec/async,file_rec/git',
      \ 'matchers', ['converter_relative_word', 'matcher_glob'])
call unite#custom#default_action('directory', 'rec/async')

if executable('ag')
  call unite#custom#source('grep', 'variables', {
        \   'command': 'ag',
        \   'default_opts': '--nocolor --nogroup --column',
        \   'recursive_opt': ''
        \ })
  call unite#custom#source('file_rec,file_rec/async', 'variables', {
        \   'async_command': ['ag', '--follow', '--nocolor',
        \                     '--nogroup', '-g', '']
        \ })
endif

call unite#custom#source('buffer', 'variables', {
      \   'time_format': '%F %R'
      \ })
