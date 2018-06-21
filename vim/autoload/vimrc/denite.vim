function! vimrc#denite#on_source() abort
  noremap <silent> <Leader>f :DeniteBufferDir file file:new<CR>
  noremap <silent> <Leader>F :DeniteBufferDir file/rec file:new<CR>
  noremap <silent> <Leader>p :DeniteProjectDir file/git file:new<CR>
  noremap <silent> <Leader>b :Denite buffer<CR>
  noremap <silent> <Leader>g :Denite grep<CR>
  noremap <silent> <Leader>h :Denite help<CR>
  noremap <silent> <Leader>l :Denite line:all:noempty<CR>
  noremap <silent> <Leader>m :Denite menu:commands<CR>
  noremap <silent> <Leader>o :Denite outline<CR>
  noremap <silent> <Leader>r :Denite register<CR>
  noremap <silent> <Leader>t :Denite filetype<CR>
endfunction

function! vimrc#denite#on_post_source() abort
  call denite#custom#option('_', {
        \   'source_names': 'short',
        \   'smartcase': v:true,
        \   'updatetime': 10
        \ })

  call denite#custom#source('file', 'converters', ['converter/relative_abbr'])

  if executable('ag')
    call denite#custom#var('file/rec', 'command',
          \ ['ag', '--hidden', '--nocolor', '--nogroup',
          \  '-p', g:vimfiles . '/.ignore', '-g', ''])

    call denite#custom#var('grep', 'command', ['ag'])
    call denite#custom#var('grep', 'default_opts', ['--nocolor', '--nogroup'])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', [])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])
  else
    call denite#custom#var('file/rec', 'command', ['scantree.py'])
  endif

  call denite#custom#alias('source', 'file/git', 'file/rec')
  call denite#custom#var('file/git', 'command',
        \ ['git', 'ls-files', '-co', '--exclude-standard'])

  call denite#custom#map(
        \ 'insert', '<C-a>', '<denite:move_caret_to_head>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-b>', '<denite:move_caret_to_left>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-e>', '<denite:move_caret_to_tail>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-f>', '<denite:move_caret_to_right>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-g>', '<denite:change_path>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-h>', '<denite:delete_char_before_caret>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-l>', '<denite:redraw>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-o>', '<denite:enter_mode:normal>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-r>', '<denite:paste_from_register>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-u>', '<denite:delete_entire_text>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-v>', '<denite:insert_special>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-w>', '<denite:delete_word_before_caret>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<C-^>', '<denite:move_up_path>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<Up>', '<denite:move_to_previous_line>', 'noremap')
  call denite#custom#map(
        \ 'insert', '<Down>', '<denite:move_to_next_line>', 'noremap')

  call denite#custom#map(
        \ 'normal', '^', '<denite:move_caret_to_lead>', 'noremap')
  call denite#custom#map(
        \ 'normal', 'g', '<denite:move_to_first_line>', 'noremap nowait')
endfunction
