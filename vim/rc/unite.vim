call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_selecta'])

call unite#custom#profile('default', 'context', {
      \   'start_insert': 1,
      \   'ignorecase': 1,
      \   'smartcase': 1,
      \   'winheight': 10
      \ })

call unite#custom#source('file,filerec,file_rec/async,file_rec/git',
      \ 'matchers', ['matcher_glob'])
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

let g:unite_source_menu_menus = {}
let g:unite_source_menu_menus.menu = {}
let g:unite_source_menu_menus.menu.candidates = {
      \   'vimrc': '~/.vim/vimrc',
      \   'vim plugins': '~/.vim/rc/',
      \   'zshrc': '~/.zsh/.zshrc',
      \   'tmux.conf': '~/.tmux.conf',
      \   'indent 2 space': ':setl et ts=2 sts=2 sw=2',
      \   'indent 4 space': ':setl et ts=4 sts=4 sw=4',
      \   'indent 8 space': ':setl et ts=8 sts=8 sw=8',
      \   'indent tab': ':setl noet ts=8 sts=8 sw=8'
      \ }
function g:unite_source_menu_menus.menu.map(key, value)
  if a:value[0] ==# ':'
    return { 'word': a:key, 'kind': 'command', 'action__command': a:value[1:] }
  elseif isdirectory(a:value)
    return { 'word': a:key, 'kind': 'directory', 'action__directory': a:value }
  else
    return { 'word': a:key, 'kind': 'file', 'action__path': a:value }
  endif
endfunction
