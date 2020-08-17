function vimrc#denite#on_source() abort
  augroup vimrc-denite
    autocmd!
    autocmd FileType denite call vimrc#denite#on_denite_buffer()
    autocmd FileType denite-filter call vimrc#denite#on_denite_filter()
  augroup END

  nnoremap <silent> <Leader>f
        \ :Denite -buffer-name=files buffer file/rec<CR>
  nnoremap <silent> <Leader>F
        \ :Denite -buffer-name=files file file:new<CR>
  nnoremap <silent> <Leader>b
        \ :DeniteBufferDir -buffer-name=files buffer file/rec<CR>
  nnoremap <silent> <Leader>p
        \ :DeniteProjectDir -buffer-name=files buffer file/git<CR>
  nnoremap <silent> <Leader>B
        \ :Denite -buffer-name=buffers buffer:!<CR>
  nnoremap <silent> <Leader>g
        \ :Denite -buffer-name=grep grep:::!<CR>
  nnoremap <silent> <Leader>G
        \ :DeniteBufferDir -buffer-name=grep grep:::!<CR>
  nnoremap <silent> <Leader>h
        \ :Denite -buffer-name=help help<CR>
  nnoremap <silent> <Leader>l
        \ :Denite -buffer-name=lines line:all:noempty<CR>
  nnoremap <silent> <Leader>r
        \ :Denite -buffer-name=quickrun -immediately-1 -input=`&filetype` quickrun<CR>
  nnoremap <silent> <Leader>R
        \ :Denite -buffer-name=registers register<CR>
  nnoremap <silent> <Leader>t
        \ :Denite -buffer-name=filetypes filetype<CR>
endfunction

function vimrc#denite#on_post_source() abort
  call denite#custom#option('_', {
        \   'filter_updatetime': 10,
        \   'smartcase': v:true,
        \   'source_names': 'short',
        \   'start_filter': v:true,
        \   'statusline': v:false,
        \ })

  if executable('rg')
    call denite#custom#var('file/rec', 'command', ['rg', '--files'])
  elseif has('win32')
    call denite#custom#var('file/rec', 'command',
         \ ['scantree.py',
         \  '--ignore', '.git,node_modules',
         \  '--path', ':directory'])
  else
    call denite#custom#var('file/rec', 'command',
          \ ['find', '-L', ':directory',
          \  '(', '-name', '.git', '-o', '-name', 'node_modules', ')',
          \  '-prune', '-o', '-type', 'f', '-print'])
  endif

  call denite#custom#alias('source', 'file/git', 'file/rec')
  call denite#custom#var('file/git', 'command',
        \ ['git', 'ls-files', '-co', '--exclude-standard'])

  call denite#custom#source('file', 'matchers',
        \ ['converter/abbr_word',
        \  'matcher/hide_hidden_files', 'matcher/fuzzy'])
  call denite#custom#source('file/rec,file/git', 'matchers',
        \ ['matcher/hide_hidden_files', 'matcher/fuzzy'])

  call denite#custom#source('buffer', 'matchers',
        \ ['matcher/project_files', 'matcher/fuzzy'])
  call denite#custom#var('buffer', 'date_format', '%F %T')
  call denite#custom#option('buffers', 'matchers', 'matcher/fuzzy')

  if executable('rg')
    call denite#custom#var('grep', 'command', ['rg'])
    call denite#custom#var('grep', 'default_opts', [
          \ '--vimgrep', '--hidden', '--glob', '!.git/'])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', [])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])
  elseif executable('ag')
    call denite#custom#var('grep', 'command', ['ag'])
    call denite#custom#var('grep', 'default_opts', [
          \ '--vimgrep', '--hidden',
          \ '--ignore', '.git',
          \ '--ignore', 'node_modules'])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', [])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])
  endif
endfunction

function vimrc#denite#on_denite_buffer() abort
  nnoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
  nnoremap <silent><buffer><expr> <Tab> denite#do_map('choose_action')
  nnoremap <silent><buffer><expr><nowait> <Space>
        \ denite#do_map('toggle_select')..'j'
  nnoremap <buffer> <Esc>[ <Esc>[
  nnoremap <silent><buffer><expr><nowait> <Esc> denite#do_map('quit')
  nnoremap <silent><buffer><expr> <C-^> denite#do_map('move_up_path')
  nnoremap <silent><buffer><expr> <C-c> denite#do_map('quit')
  nnoremap <silent><buffer><expr> <C-l> denite#do_map('redraw')
  nnoremap <silent><buffer><expr> <C-r> denite#do_map('restart')
  nnoremap <silent><buffer><expr> <C-u> denite#do_map('filter', '')
  nnoremap <silent><buffer><expr> * denite#do_map('toggle_select_all')
  nnoremap <silent><buffer><expr> S denite#do_map('do_action', 'split')
  nnoremap <silent><buffer><expr> ^ denite#do_map('move_up_path')
  nnoremap <silent><buffer><expr> a denite#do_map('do_action', 'append')
  nnoremap <silent><buffer><expr> c denite#do_map('change_path')
  nnoremap <silent><buffer><expr> i denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> o denite#do_map('do_action', 'open')
  nnoremap <silent><buffer><expr> p denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q denite#do_map('quit')
  nnoremap <silent><buffer><expr> s denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> t denite#do_map('do_action', 'tabopen')
  nnoremap <silent><buffer><expr> y denite#do_map('do_action', 'yank')
  nnoremap <silent><buffer> ? :nmap <buffer><CR>
endfunction

function vimrc#denite#on_denite_filter() abort
  let b:lexima_disabled = 1
  let b:asyncomplete_enable = 0
  if dein#is_sourced('deoplete.nvim')
    call deoplete#custom#buffer_option('auto_complete', v:false)
  endif

  inoremap <silent><buffer> <Plug>(denite-filter-up)
        \ <C-o>:call vimrc#denite#move_cursor('up')<CR>
  inoremap <silent><buffer> <Plug>(denite-filter-down)
        \ <C-o>:call vimrc#denite#move_cursor('down')<CR>

  inoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
  inoremap <silent><buffer><expr> <Tab> denite#do_map('choose_action')
  inoremap <silent><buffer><expr> <C-^> denite#do_map('move_up_path')
  inoremap <silent><buffer><expr> <C-c> denite#do_map('quit')
  inoremap <silent><buffer><expr> <C-l> denite#do_map('redraw')
  inoremap <silent><buffer><expr> <C-r> denite#do_map('restart')
  imap <silent><buffer><nowait> <Esc> <Plug>(denite_filter_quit)
  imap <silent><buffer> <C-n> <Plug>(denite-filter-down)
  imap <silent><buffer> <C-p> <Plug>(denite-filter-up)
  imap <silent><buffer> <Down> <Plug>(denite-filter-down)
  imap <silent><buffer> <Up> <Plug>(denite-filter-up)

  inoremap <buffer> <C-a> <Home>
  inoremap <buffer> <C-b> <Left>
  inoremap <buffer> <C-e> <End>
  inoremap <buffer> <C-f> <Right>
  inoremap <buffer> <C-u> <C-o>"_dd
endfunction

function vimrc#denite#move_cursor(direction) abort
  let winid = bufwinid(g:denite#_filter_parent)
  if a:direction ==# 'up'
    call win_execute(winid, 'normal! k')
  else
    call win_execute(winid, 'normal! j')
  endif
endfunction
